﻿package com.ankamagames.jerakine.resources.loaders.impl
{
    import com.ankamagames.jerakine.resources.loaders.AbstractRessourceLoader;
    import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
    import com.ankamagames.jerakine.resources.IResourceObserver;
    import flash.utils.Dictionary;
    import com.ankamagames.jerakine.types.Uri;
    import com.ankamagames.jerakine.newCache.ICache;
    import com.ankamagames.jerakine.resources.protocols.IProtocol;
    import com.ankamagames.jerakine.resources.protocols.ProtocolFactory;
    import com.ankamagames.jerakine.resources.events.ResourceProgressEvent;

    public class ParallelRessourceLoader extends AbstractRessourceLoader implements IResourceLoader, IResourceObserver 
    {

        public static var MEMORY_LOG:Dictionary = new Dictionary(true);

        private var _maxParallel:uint;
        private var _uris:Array;
        private var _currentlyLoading:uint;
        private var _loadDictionnary:Dictionary;

        public function ParallelRessourceLoader(maxParallel:uint)
        {
            this._maxParallel = maxParallel;
            this._loadDictionnary = new Dictionary(true);
            MEMORY_LOG[this] = 1;
        }

        public function load(uris:*, cache:ICache=null, forcedAdapter:Class=null, singleFile:Boolean=false):void
        {
            var newUris:Array;
            var uri:Uri;
            if ((uris is Uri))
            {
                newUris = [uris];
            }
            else
            {
                if ((uris is Array))
                {
                    newUris = uris;
                }
                else
                {
                    throw (new ArgumentError("URIs must be an array or an Uri instance."));
                };
            };
            var mustStartLoading:Boolean;
            if (this._uris != null)
            {
                for each (uri in newUris)
                {
                    this._uris.push({
                        "uri":uri,
                        "forcedAdapter":forcedAdapter,
                        "singleFile":singleFile
                    });
                };
                if (this._currentlyLoading == 0)
                {
                    mustStartLoading = true;
                };
            }
            else
            {
                this._uris = new Array();
                for each (uri in newUris)
                {
                    this._uris.push({
                        "uri":uri,
                        "forcedAdapter":forcedAdapter,
                        "singleFile":singleFile
                    });
                };
                mustStartLoading = true;
            };
            _cache = cache;
            _completed = false;
            _filesTotal = (_filesTotal + this._uris.length);
            if (mustStartLoading)
            {
                this.loadNextUris();
            };
        }

        override public function cancel():void
        {
            var p:IProtocol;
            super.cancel();
            for each (p in this._loadDictionnary)
            {
                if (p)
                {
                    p.free();
                    p.cancel();
                    p = null;
                };
            };
            this._loadDictionnary = new Dictionary(true);
            this._currentlyLoading = 0;
            this._uris = [];
        }

        private function loadNextUris():void
        {
            var loadData:Object;
            var p:IProtocol;
            if (this._uris.length == 0)
            {
                this._uris = null;
                return;
            };
            this._currentlyLoading = Math.min(this._maxParallel, this._uris.length);
            var starterLoop:uint = this._currentlyLoading;
            var i:uint;
            while (i < starterLoop)
            {
                loadData = this._uris.shift();
                if (!(checkCache(loadData.uri)))
                {
                    p = ProtocolFactory.getProtocol(loadData.uri);
                    this._loadDictionnary[loadData.uri] = p;
                    p.load(loadData.uri, this, hasEventListener(ResourceProgressEvent.PROGRESS), _cache, loadData.forcedAdapter, loadData.singleFile);
                }
                else
                {
                    this.decrementLoads();
                };
                i++;
            };
        }

        private function decrementLoads():void
        {
            this._currentlyLoading--;
            if (this._currentlyLoading == 0)
            {
                this.loadNextUris();
            };
        }

        override public function onLoaded(uri:Uri, resourceType:uint, resource:*):void
        {
            super.onLoaded(uri, resourceType, resource);
            delete this._loadDictionnary[uri];
            this.decrementLoads();
        }

        override public function onFailed(uri:Uri, errorMsg:String, errorCode:uint):void
        {
            super.onFailed(uri, errorMsg, errorCode);
            delete this._loadDictionnary[uri];
            this.decrementLoads();
        }


    }
}//package com.ankamagames.jerakine.resources.loaders.impl

