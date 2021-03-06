﻿package com.ankamagames.berilia.utils
{
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import com.ankamagames.jerakine.newCache.ICache;
    import com.ankamagames.jerakine.types.Uri;

    public class UriCacheFactory 
    {

        private static var _log:Logger = Log.getLogger(getQualifiedClassName(UriCacheFactory));
        private static var _aCache:Array = new Array();


        public static function init(path:String, cacheClass:ICache):ICache
        {
            _aCache[path] = cacheClass;
            return (cacheClass);
        }

        public static function getCacheFromUri(uri:Uri):ICache
        {
            var key:String;
            var currentPath:String = uri.normalizedUri;
            for (key in _aCache)
            {
                if (currentPath.indexOf(key) != -1)
                {
                    return (_aCache[key]);
                };
            };
            return (null);
        }

        public static function get caches():Array
        {
            return (_aCache);
        }


    }
}//package com.ankamagames.berilia.utils

