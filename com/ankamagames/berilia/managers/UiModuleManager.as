package com.ankamagames.berilia.managers
{
   import com.ankamagames.jerakine.logger.Logger;
   import com.ankamagames.jerakine.logger.Log;
   import flash.utils.getQualifiedClassName;
   import com.ankamagames.jerakine.resources.loaders.IResourceLoader;
   import flash.system.ApplicationDomain;
   import flash.utils.Dictionary;
   import flash.filesystem.File;
   import com.ankamagames.jerakine.types.Uri;
   import com.ankamagames.berilia.utils.web.HttpServer;
   import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSwfAdapter;
   import com.ankamagames.jerakine.utils.display.FrameIdManager;
   import com.ankamagames.jerakine.utils.display.StageShareManager;
   import com.ankamagames.jerakine.utils.display.EnterFrameDispatcher;
   import com.ankamagames.jerakine.utils.system.AirScanner;
   import com.ankamagames.jerakine.resources.protocols.ProtocolFactory;
   import com.ankamagames.berilia.utils.ModProtocol;
   import com.ankamagames.berilia.utils.ModFlashProtocol;
   import com.ankamagames.jerakine.managers.LangManager;
   import com.ankamagames.jerakine.managers.ErrorManager;
   import com.ankamagames.berilia.types.data.UiModule;
   import com.ankamagames.berilia.types.shortcut.Shortcut;
   import com.ankamagames.berilia.Berilia;
   import com.ankamagames.berilia.api.ApiBinder;
   import com.ankamagames.berilia.types.graphic.UiRootContainer;
   import com.ankamagames.berilia.types.data.UiGroup;
   import com.ankamagames.berilia.utils.errors.UntrustedApiCallError;
   import com.ankamagames.jerakine.utils.misc.DescribeTypeCache;
   import flash.events.Event;
   import flash.utils.getTimer;
   import com.ankamagames.berilia.types.messages.AllModulesLoadedMessage;
   import com.ankamagames.jerakine.resources.adapters.impl.TxtAdapter;
   import com.ankamagames.jerakine.newCache.ICache;
   import com.ankamagames.jerakine.utils.files.FileUtils;
   import com.ankamagames.berilia.utils.UriCacheFactory;
   import com.ankamagames.jerakine.newCache.impl.Cache;
   import com.ankamagames.jerakine.newCache.garbage.LruGarbageCollector;
   import com.ankamagames.jerakine.resources.events.ResourceErrorEvent;
   import com.ankamagames.berilia.types.messages.ModuleRessourceLoadFailedMessage;
   import flash.system.LoaderContext;
   import com.ankamagames.jerakine.resources.events.ResourceLoadedEvent;
   import flash.filesystem.FileStream;
   import flash.utils.ByteArray;
   import com.ankamagames.jerakine.utils.crypto.Signature;
   import com.ankamagames.berilia.types.data.UiData;
   import com.ankamagames.jerakine.resources.ResourceType;
   import com.ankamagames.berilia.types.data.PreCompiledUiModule;
   import com.ankamagames.jerakine.utils.misc.StringUtils;
   import flash.filesystem.FileMode;
   import by.blooddy.crypto.MD5;
   import com.ankamagames.jerakine.resources.adapters.impl.SignedFileAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.BinaryAdapter;
   import com.ankamagames.jerakine.resources.adapters.impl.AdvancedSignedFileAdapter;
   import flash.events.IOErrorEvent;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import com.ankamagames.berilia.types.messages.ModuleLoadedMessage;
   import com.ankamagames.berilia.types.shortcut.ShortcutCategory;
   import com.ankamagames.jerakine.resources.events.ResourceLoaderProgressEvent;
   import com.ankamagames.berilia.uiRender.XmlParsor;
   import com.ankamagames.berilia.types.event.ParsingErrorEvent;
   import com.ankamagames.berilia.types.messages.AllUiXmlParsedMessage;
   import com.ankamagames.berilia.types.event.ParsorEvent;
   import com.ankamagames.berilia.types.messages.UiXmlParsedMessage;
   import com.ankamagames.berilia.types.messages.UiXmlParsedErrorMessage;
   import com.ankamagames.jerakine.types.ASwf;
   import com.ankamagames.jerakine.utils.errors.SingletonError;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderFactory;
   import com.ankamagames.jerakine.resources.loaders.ResourceLoaderType;
   
   public class UiModuleManager extends Object
   {
      
      public function UiModuleManager(dontUseLocalServer:Boolean = false) {
         this._regImport = new RegExp("<Import *url *= *\"([^\"]*)","g");
         this._modulesHashs = new Dictionary();
         this._moduleScriptLoadedRef = new Dictionary();
         this._uiLoaded = new Dictionary();
         super();
         if(_self)
         {
            throw new SingletonError();
         }
         else
         {
            this._loader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
            this._loader.addEventListener(ResourceErrorEvent.ERROR,this.onLoadError,false,0,true);
            this._loader.addEventListener(ResourceLoadedEvent.LOADED,this.onLoad,false,0,true);
            this._sharedDefinitionLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.SINGLE_LOADER);
            this._sharedDefinitionLoader.addEventListener(ResourceErrorEvent.ERROR,this.onLoadError,false,0,true);
            this._sharedDefinitionLoader.addEventListener(ResourceLoadedEvent.LOADED,this.onSharedDefinitionLoad,false,0,true);
            this._uiLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
            this._uiLoader.addEventListener(ResourceErrorEvent.ERROR,this.onUiLoadError,false,0,true);
            this._uiLoader.addEventListener(ResourceLoadedEvent.LOADED,this.onUiLoaded,false,0,true);
            this._cacheLoader = ResourceLoaderFactory.getLoader(ResourceLoaderType.PARALLEL_LOADER);
            this._moduleLoaders = new Dictionary();
            this._useHttpServer = false;
            if((!dontUseLocalServer) && (ApplicationDomain.currentDomain.hasDefinition("flash.net.ServerSocket")))
            {
               this._useHttpServer = true;
            }
            if(this._useHttpServer)
            {
               HttpServer.getInstance().init(File.applicationDirectory);
            }
            return;
         }
      }
      
      protected static const _log:Logger;
      
      private static const _lastModulesToUnload:Array;
      
      private static var _self:UiModuleManager;
      
      public static function getInstance(dontUseLocalServer:Boolean = false) : UiModuleManager {
         if(!_self)
         {
            _self = new UiModuleManager(dontUseLocalServer);
         }
         return _self;
      }
      
      private var _sharedDefinitionLoader:IResourceLoader;
      
      private var _sharedDefinition:ApplicationDomain;
      
      private var _useSharedDefinition:Boolean;
      
      private var _loader:IResourceLoader;
      
      private var _uiLoader:IResourceLoader;
      
      private var _scriptNum:uint;
      
      private var _modules:Array;
      
      private var _preprocessorIndex:Dictionary;
      
      private var _uiFiles:Array;
      
      private var _regImport:RegExp;
      
      private var _versions:Array;
      
      private var _clearUi:Array;
      
      private var _uiFileToLoad:uint;
      
      private var _moduleCount:uint = 0;
      
      private var _cacheLoader:IResourceLoader;
      
      private var _unparsedXml:Array;
      
      private var _unparsedXmlCount:uint;
      
      private var _unparsedXmlTotalCount:uint;
      
      private var _modulesRoot:File;
      
      private var _modulesPaths:Dictionary;
      
      private var _modulesHashs:Dictionary;
      
      private var _resetState:Boolean;
      
      private var _parserAvaibleCount:uint = 2;
      
      private var _moduleLaunchWaitForSharedDefinition:Boolean;
      
      private var _unInitializedModules:Array;
      
      public function get unInitializedModules() : Array {
         return this._unInitializedModules;
      }
      
      private var _useHttpServer:Boolean;
      
      private var _moduleLoaders:Dictionary;
      
      private var _loadingModule:Dictionary;
      
      private var _disabledModules:Array;
      
      private var _sharedDefinitionInstance:Object;
      
      private var _timeOutFrameNumber:int;
      
      private var _waitingInit:Boolean;
      
      private var _filter:Array;
      
      private var _filterInclude:Boolean;
      
      public var isDevMode:Boolean;
      
      public function get moduleCount() : uint {
         return this._moduleCount;
      }
      
      public function get unparsedXmlCount() : uint {
         return this._unparsedXmlCount;
      }
      
      public function get unparsedXmlTotalCount() : uint {
         return this._unparsedXmlTotalCount;
      }
      
      public function set sharedDefinitionContainer(path:Uri) : void {
         var url:String = null;
         var sharedDefinitionUri:Uri = null;
         this._useSharedDefinition = !(path == null);
         if(path)
         {
            if(this._useHttpServer)
            {
               url = HttpServer.getInstance().getUrlTo(path.fileName);
               sharedDefinitionUri = new Uri(url);
               _log.debug("sharedDefinition.swf location: " + path.uri + " (" + url + ")");
               this._sharedDefinitionLoader.load(sharedDefinitionUri,null,path.fileType == "swf"?AdvancedSwfAdapter:null);
               _log.info("trying to load sharedDefinition.swf throught an httpServer");
               this._timeOutFrameNumber = StageShareManager.stage.frameRate * 10;
               EnterFrameDispatcher.addEventListener(this.timeOutFrameCount,"frameCount");
            }
            else
            {
               this._sharedDefinitionLoader.load(path,null,path.fileType == "swf"?AdvancedSwfAdapter:null);
               _log.info("trying to load sharedDefinition.swf the good ol\' way");
            }
         }
      }
      
      public function get sharedDefinition() : ApplicationDomain {
         return this._sharedDefinition;
      }
      
      public function get ready() : Boolean {
         return !(this._sharedDefinition == null);
      }
      
      public function get sharedDefinitionInstance() : Object {
         return this._sharedDefinitionInstance;
      }
      
      public function get modulesHashs() : Dictionary {
         return this._modulesHashs;
      }
      
      public function init(filter:Array, filterInclude:Boolean) : void {
         var uri:Uri = null;
         var file:File = null;
         this._filter = filter;
         this._filterInclude = filterInclude;
         if(!this._sharedDefinition)
         {
            this._waitingInit = true;
            return;
         }
         this._moduleLaunchWaitForSharedDefinition = false;
         this._resetState = false;
         this._modules = new Array();
         this._preprocessorIndex = new Dictionary(true);
         this._scriptNum = 0;
         this._moduleCount = 0;
         this._versions = new Array();
         this._clearUi = new Array();
         this._uiFiles = new Array();
         this._modulesPaths = new Dictionary();
         this._unInitializedModules = new Array();
         this._loadingModule = new Dictionary();
         this._disabledModules = [];
         if(AirScanner.hasAir())
         {
            ProtocolFactory.addProtocol("mod",ModProtocol);
         }
         else
         {
            ProtocolFactory.addProtocol("mod",ModFlashProtocol);
         }
         var uiRoot:String = LangManager.getInstance().getEntry("config.mod.path");
         if((!(uiRoot.substr(0,2) == "\\\\")) && (!(uiRoot.substr(1,2) == ":/")))
         {
            this._modulesRoot = new File(File.applicationDirectory.nativePath + File.separator + uiRoot);
         }
         else
         {
            this._modulesRoot = new File(uiRoot);
         }
         uri = new Uri(this._modulesRoot.nativePath + "/hash.metas");
         this._loader.load(uri);
         BindsManager.getInstance().initialize();
         if(this._modulesRoot.exists)
         {
            for each(file in this._modulesRoot.getDirectoryListing())
            {
               if(!((!file.isDirectory) || (file.name.charAt(0) == ".")))
               {
                  if(!(filter.indexOf(file.name) == -1) == filterInclude)
                  {
                     this.loadModule(file.name);
                  }
               }
            }
            return;
         }
         ErrorManager.addError("Impossible de trouver le dossier contenant les modules (url: " + LangManager.getInstance().getEntry("config.mod.path") + ")");
      }
      
      public function lightInit(moduleList:Vector.<UiModule>) : void {
         var m:UiModule = null;
         this._resetState = false;
         this._modules = new Array();
         this._modulesPaths = new Dictionary();
         for each(this._modules[m.id] in moduleList)
         {
            this._modulesPaths[m.id] = m.rootPath;
         }
      }
      
      public function getModules() : Array {
         return this._modules;
      }
      
      public function getModule(name:String, includeUnInitialized:Boolean = false) : UiModule {
         var module:UiModule = null;
         if(this._modules)
         {
            module = this._modules[name];
         }
         if((!module) && (includeUnInitialized) && (this._unInitializedModules))
         {
            module = this._unInitializedModules[name];
         }
         return module;
      }
      
      public function get disabledModules() : Array {
         return this._disabledModules;
      }
      
      public function reset() : void {
         var module:UiModule = null;
         var i:* = 0;
         _log.warn("Reset des modules");
         this._resetState = true;
         if(this._loader)
         {
            this._loader.cancel();
         }
         if(this._cacheLoader)
         {
            this._cacheLoader.cancel();
         }
         if(this._uiLoader)
         {
            this._uiLoader.cancel();
         }
         TooltipManager.clearCache();
         for each(module in this._modules)
         {
            if(_lastModulesToUnload.indexOf(module.id) == -1)
            {
               this.unloadModule(module.id);
            }
         }
         i = 0;
         while(i < _lastModulesToUnload.length)
         {
            if(this._modules[_lastModulesToUnload[i]])
            {
               this.unloadModule(_lastModulesToUnload[i]);
            }
            i++;
         }
         Shortcut.reset();
         Berilia.getInstance().reset();
         ApiBinder.reset();
         KernelEventsManager.getInstance().initialize();
         this._modules = [];
         this._uiFileToLoad = 0;
         this._scriptNum = 0;
         this._moduleCount = 0;
         this._parserAvaibleCount = 2;
         this._modulesPaths = new Dictionary();
      }
      
      public function getModulePath(moduleName:String) : String {
         return this._modulesPaths[moduleName];
      }
      
      public function loadModule(id:String) : void {
         var dmFile:File = null;
         var uri:Uri = null;
         var modulePath:String = null;
         var len:* = 0;
         var substr:String = null;
         this.unloadModule(id);
         var targetedModuleFolder:File = this._modulesRoot.resolvePath(id);
         if(targetedModuleFolder.exists)
         {
            dmFile = this.searchDmFile(targetedModuleFolder);
            if(dmFile)
            {
               this._moduleCount++;
               this._scriptNum++;
               if(dmFile.nativePath.indexOf("app:/") == 0)
               {
                  len = "app:/".length;
                  substr = dmFile.nativePath.substring(len,dmFile.url.length);
                  uri = new Uri(substr);
                  modulePath = substr.substr(0,substr.lastIndexOf("/"));
               }
               else
               {
                  uri = new Uri(dmFile.nativePath);
                  modulePath = dmFile.parent.nativePath;
               }
               uri.tag = dmFile;
               this._modulesPaths[id] = modulePath;
               this._loader.load(uri);
            }
            else
            {
               _log.error("Cannot found .dm or .d2ui file in " + targetedModuleFolder.url);
            }
         }
      }
      
      public function unloadModule(id:String) : void {
         var uiCtr:UiRootContainer = null;
         var ui:String = null;
         var group:UiGroup = null;
         var variables:Array = null;
         var varName:String = null;
         var apiList:Vector.<Object> = null;
         var api:Object = null;
         if(this._modules == null)
         {
            return;
         }
         var m:UiModule = this._modules[id];
         if(!m)
         {
            return;
         }
         var moduleUiInstances:Array = [];
         for each(uiCtr in Berilia.getInstance().uiList)
         {
            if(uiCtr.uiModule == m)
            {
               moduleUiInstances.push(uiCtr.name);
            }
         }
         for each(ui in moduleUiInstances)
         {
            Berilia.getInstance().unloadUi(ui);
         }
         for each(group in m.groups)
         {
            UiGroupManager.getInstance().removeGroup(group.name);
         }
         variables = DescribeTypeCache.getVariables(m.mainClass,true);
         for each(varName in variables)
         {
            if(m.mainClass[varName] is Object)
            {
               m.mainClass[varName] = null;
            }
         }
         m.destroy();
         apiList = m.apiList;
         while(apiList.length)
         {
            api = apiList.shift();
            if((api) && (api.hasOwnProperty("destroy")))
            {
               try
               {
                  api["destroy"]();
               }
               catch(e:UntrustedApiCallError)
               {
                  api["destroy"](SecureCenter.ACCESS_KEY);
                  continue;
               }
            }
         }
         if((m.mainClass) && (m.mainClass.hasOwnProperty("unload")))
         {
            m.mainClass["unload"]();
         }
         BindsManager.getInstance().removeEventListenerByName("__module_" + m.id);
         KernelEventsManager.getInstance().removeEventListenerByName("__module_" + m.id);
         delete this._modules[id];
         this._disabledModules[id] = m;
      }
      
      public function checkSharedDefinitionHash(hashUrl:String) : void {
         var hashUri:Uri = new Uri(hashUrl);
      }
      
      private function onTimeOut() : void {
         var _loc1_:* = false;
         var _loc2_:* = true;
         _log.error("SharedDefinition load Timeout");
         this.switchToNoHttpMode();
         EnterFrameDispatcher.removeEventListener(this.timeOutFrameCount);
      }
      
      private function timeOutFrameCount(e:Event) : void {
         var _loc4_:* = false;
         var _loc5_:* = true;
         this._timeOutFrameNumber--;
         if(this._timeOutFrameNumber <= 0)
         {
            this.onTimeOut();
         }
      }
      
      private function launchModule() : void {
         var _loc10_:* = true;
         var _loc11_:* = false;
         var module:UiModule = null;
         var missingName:String = null;
         var missingModule:UiModule = null;
         var notLoaded:Array = null;
         var m:UiModule = null;
         var ts:uint = 0;
         this._moduleLaunchWaitForSharedDefinition = false;
         var modules:Array = new Array();
         for each(module in this._unInitializedModules)
         {
            if(module.trusted)
            {
               modules.unshift(module);
            }
            else
            {
               modules.push(module);
            }
         }
         while(modules.length > 0)
         {
            notLoaded = new Array();
            for each(m in modules)
            {
               ApiBinder.addApiData("currentUi",null);
               missingName = ApiBinder.initApi(m.mainClass,m,this._sharedDefinition);
               if(missingName)
               {
                  missingModule = m;
                  notLoaded.push(m);
               }
               else if(m.mainClass)
               {
                  delete this._unInitializedModules[m.id];
                  ts = getTimer();
                  ErrorManager.tryFunction(m.mainClass.main,null,"Une erreur est survenue lors de l\'appel à la fonction main() du module " + m.id);
               }
               else
               {
                  _log.error("Impossible d\'instancier la classe principale du module " + m.id);
               }
               
            }
            if(notLoaded.length == modules.length)
            {
               ErrorManager.addError("Le module " + missingModule.id + " demande une référence vers un module inexistant : " + missingName);
            }
            modules = notLoaded;
         }
         Berilia.getInstance().handler.process(new AllModulesLoadedMessage());
      }
      
      private function launchUiCheck() : void {
         var _loc1_:* = false;
         var _loc2_:* = true;
         this._uiFileToLoad = this._uiFiles.length;
         if(this._uiFiles.length)
         {
            this._uiLoader.load(this._uiFiles,null,TxtAdapter);
         }
         else
         {
            this.onAllUiChecked(null);
         }
      }
      
      private function processCachedFiles(files:Array) : void {
         var _loc8_:* = false;
         var _loc9_:* = true;
         var uri:Uri = null;
         var file:Uri = null;
         var c:ICache = null;
         for each(file in files)
         {
         }
      }
      
      private function onLoadError(e:ResourceErrorEvent) : void {
         var _loc5_:* = false;
         var _loc6_:* = true;
         _log.error("onLoadError() - " + e.errorMsg);
         var sduri:Uri = new Uri(HttpServer.getInstance().getUrlTo("SharedDefinitions.swf"));
         if(e.uri == sduri)
         {
            this.switchToNoHttpMode();
         }
         else if(e.uri.fileType != "metas")
         {
            Berilia.getInstance().handler.process(new ModuleRessourceLoadFailedMessage(e.uri.tag,e.uri));
         }
         
         if(e.uri == sduri)
         {
            return;
         }
      }
      
      private function switchToNoHttpMode() : void {
         var _loc2_:* = true;
         var _loc3_:* = false;
         this._useHttpServer = false;
         _log.fatal("Failed Loading SharedDefinitions, Going no HttpServer Style !");
         this._sharedDefinitionLoader.cancel();
         var sharedDefUri:Uri = new Uri("SharedDefinitions.swf");
         sharedDefUri.loaderContext = new LoaderContext(false,new ApplicationDomain());
         this.sharedDefinitionContainer = sharedDefUri;
      }
      
      private function onUiLoadError(e:ResourceErrorEvent) : void {
         var _loc4_:* = true;
         var _loc5_:* = false;
         ErrorManager.addError("Impossible de charger le fichier d\'interface " + e.uri + " (" + e.errorMsg + ")");
         Berilia.getInstance().handler.process(new ModuleRessourceLoadFailedMessage(e.uri.tag,e.uri));
         this._uiFileToLoad--;
      }
      
      private function onLoad(e:ResourceLoadedEvent) : void {
         var _loc3_:* = true;
         var _loc4_:* = false;
         if(this._resetState)
         {
            return;
         }
         switch(e.uri.fileType.toLowerCase())
         {
            case "swf":
            case "swfs":
               this.onScriptLoad(e);
               break;
            case "d2ui":
            case "dm":
               this.onDMLoad(e);
               break;
            case "xml":
               this.onShortcutLoad(e);
               break;
            case "metas":
               this.onHashLoaded(e);
               break;
         }
      }
      
      private function onDMLoad(e:ResourceLoadedEvent) : void {
         var um:UiModule;
         var uiUri:Uri;
         var currentFile:File;
         var path:String;
         var scriptUrl:String;
         var scriptUri:Uri;
         var scriptFile:File;
         var fs:FileStream;
         var swfContent:ByteArray;
         var fooOutput:ByteArray;
         var sig:Signature;
         var shortcutsUri:Uri;
         var mp:String;
         var ui:UiData;
         var _local_18:Array;
         var _local_19:File;
         for (;;) {
             goto _label_3;
             
         _label_1: 
             continue;
             goto _label_1;
             var _local_24 = _local_24;
             
         _label_2: 
             goto _label_4;
         };
         
     _label_3: 
         goto _label_2;
         
     _label_4: 
         if (e.resourceType == ResourceType.RESOURCE_XML){
             um = UiModule.createFromXml((e.resource as XML), FileUtils.getFilePath(e.uri.path), File(e.uri.tag).parent.name);
         } else {
             um = PreCompiledUiModule.fromRaw(e.resource, FileUtils.getFilePath(e.uri.path), File(e.uri.tag).parent.name);
             goto _label_6;
         };
         
     _label_5: 
         this._unInitializedModules[um.id] = um;
         goto _label_7;
         
     _label_6: 
         goto _label_5;
         
     _label_7: 
         if (um.script){
             goto _label_13;
             
         _label_8: 
             scriptUri = new Uri(scriptUrl);
             goto _label_12;
             
         _label_9: 
             goto _label_8;
             
         _label_10: 
             scriptUrl = StringUtils.convertLatinToUtf(unescape(um.script));
             goto _label_9;
             
         _label_11: 
             goto _label_10;
             
         _label_12: 
             goto _label_14;
             
         _label_13: 
             goto _label_11;
             
         _label_14: 
             if (Berilia.getInstance().checkModuleAuthority){
                 goto _label_18;
                 
             _label_15: 
                 goto _label_19;
                 
             _label_16: 
                 scriptFile = scriptUri.toFile();
                 goto _label_15;
                 var root = root;
                 
             _label_17: 
                 goto _label_20;
                 
             _label_18: 
                 goto _label_16;
                 
             _label_19: 
                 _log.debug(("hash " + scriptUri));
                 goto _label_17;
                 var _local_20 = _local_20;
                 
             _label_20: 
                 if (scriptFile.exists){
                     goto _label_26;
                     
                 _label_21: 
                     fs.readBytes(swfContent);
                     while (true) {
                         fs.close();
                         goto _label_29;
                         
                     _label_22: 
                         fs.open(scriptFile, FileMode.READ);
                         goto _label_25;
                         
                     _label_23: 
                         goto _label_28;
                     };
                     
                 _label_24: 
                     goto _label_21;
                     
                 _label_25: 
                     swfContent = new ByteArray();
                     goto _label_24;
                     
                 _label_26: 
                     goto _label_23;
                     var _local_22 = _local_22;
                     
                 _label_27: 
                     goto _label_22;
                     
                 _label_28: 
                     fs = new FileStream();
                     goto _label_27;
                     var files = files;
                     
                 _label_29: 
                     if (scriptUri.fileType == "swf"){
                         while ((um.trusted = (MD5.hashBytes(swfContent) == this._modulesHashs[scriptUri.fileName])), true) {
                             goto _label_30;
                         };
                         
                     _label_30: 
                         if (!(um.trusted)){
                             _log.error(("Hash incorrect pour le module " + um.id));
                         };
                     } else {
                         if (scriptUri.fileType == "swfs"){
                             while ((fooOutput = new ByteArray()), true) {
                                 goto _label_31;
                             };
                             
                         _label_31: 
                             sig = new Signature(SignedFileAdapter.defaultSignatureKey);
                             if (!(sig.verify(swfContent, fooOutput))){
                                 _log.fatal(("Invalid signature in " + scriptFile.nativePath));
                                 this._moduleCount--;
                                 this._scriptNum--;
                                 um.trusted = false;
                                 while (true) {
                                     return;
                                 };
                             };
                             um.trusted = true;
                         };
                     };
                 } else {
                     ErrorManager.addError((((("Le script du module " + um.id) + " est introuvable (url: ") + scriptFile.nativePath) + ")"));
                     this._moduleCount--;
                     this._scriptNum--;
                     while ((um.trusted = false), true) {
                         return;
                     };
                     return;
                 };
             } else {
                 um.trusted = true;
             };
             if (!(um.enable)){
                 _log.fatal((("Le module " + um.id) + " est désactivé"));
                 this._moduleCount--;
                 this._scriptNum--;
                 this._disabledModules[um.id] = um;
                 while (true) {
                     return;
                 };
             };
             if (um.shortcuts){
                 goto _label_33;
                 
             _label_32: 
                 shortcutsUri.tag = um.id;
                 for (;;) {
                     goto _label_32;
                     var _local_23 = _local_23;
                     
                 _label_33: 
                     continue;
                     this._loader.load(shortcutsUri);
                     goto _label_34;
                 };
             };
             
         _label_34: 
             if (((this._useHttpServer) && (!((scriptUri.fileType == "swfs"))))){
                 while ((mp = File.applicationDirectory.nativePath.split("\\").join("/")), true) {
                     goto _label_35;
                 };
                 
             _label_35: 
                 if (scriptUrl.indexOf(mp) != -1){
                     goto _label_37;
                     
                 _label_36: 
                     _log.trace(("[WebServer] Load " + scriptUrl));
                     goto _label_42;
                     
                 _label_37: 
                     scriptUrl = scriptUrl.substr((scriptUrl.indexOf(mp) + mp.length));
                     goto _label_39;
                 };
                 
             _label_38: 
                 scriptUrl = HttpServer.getInstance().getUrlTo(scriptUrl);
                 goto _label_40;
                 
             _label_39: 
                 goto _label_38;
                 
             _label_40: 
                 goto _label_36;
                 var _local_0 = this;
                 
             _label_41: 
                 _local_0._loadModuleFunction(scriptUrl, _local_0.onModuleScriptLoaded, _local_0.onScriptLoadFail, um);
                 //unresolved jump
                 
             _label_42: 
                 goto _label_41;
             } else {
                 if (um.trusted){
                     goto _label_46;
                     
                 _label_43: 
                     goto _label_48;
                     
                 _label_44: 
                     scriptUri.loaderContext = new LoaderContext();
                     for (;;goto _label_44, (files = files)) {
                         scriptUri.loaderContext.applicationDomain = new ApplicationDomain(this._sharedDefinition);
                         goto _label_43;
                         
                     _label_45: 
                         _log.trace(("[Classic] Load " + scriptUri));
                         goto _label_49;
                         
                     _label_46: 
                         scriptUri.tag = um.id;
                         continue;
                         
                     _label_47: 
                         goto _label_45;
                     };
                     
                 _label_48: 
                     this._loadingModule[um] = um.id;
                     goto _label_47;
                     
                 _label_49: 
                     this._loader.load(scriptUri, null, ((!((scriptUri.fileType == "swfs"))) ? BinaryAdapter : AdvancedSignedFileAdapter));
                 } else {
                     this._moduleCount--;
                     this._scriptNum--;
                     goto _label_52;
                     
                 _label_50: 
                     return;
                     
                 _label_51: 
                     goto _label_50;
                     
                 _label_52: 
                     ErrorManager.addError((((("Failed to load custom module " + um.author) + "_") + um.name) + ", because the local HTTP server is not available."));
                     goto _label_51;
                 };
             };
         };
         files = new Array();
         if (!((um is PreCompiledUiModule))){
             _loop_1:
             for each (ui in um.uis) {
                 if (ui.file){
                     //unresolved jump
                     
                 _label_53: 
                     uiUri.tag = {
                         "mod":um.id,
                         "base":ui.file
                     };
                     while (//unresolved jump
, (uiUri = new Uri(ui.file)), goto _label_54, (ui = ui), this._uiFiles.push(uiUri), true) {
                         continue _loop_1;
                         
                     _label_54: 
                         goto _label_53;
                     };
                 };
             };
         };
         root = this._modulesRoot.resolvePath(um.id);
         files = new Array();
         for each (path in um.cachedFiles) {
             //unresolved jump
             
         _label_55: 
             if (currentFile.exists){
                 if (!(currentFile.isDirectory)){
                     files.push(new Uri(((("mod://" + um.id) + "/") + path)));
                 } else {
                     _local_18 = currentFile.getDirectoryListing();
                     for each (_local_19 in _local_18) {
                         if (!(_local_19.isDirectory)){
                             goto _label_57;
                             
                         _label_56: 
                             continue;
                         };
                         
                     _label_57: 
                         files.push(new Uri(((((("mod://" + um.id) + "/") + path) + "/") + FileUtils.getFileName(_local_19.url))));
                         goto _label_56;
                     };
                 };
             };
         };
         while (this.processCachedFiles(files), true) {
             return;
         };
         return;
      }
      
      private function onScriptLoadFail(e:IOErrorEvent, uiModule:UiModule) : void {
         var _loc5_:* = true;
         var _loc6_:* = false;
         _log.error("Le script du module " + uiModule.id + " est introuvable");
         if(!--this._scriptNum)
         {
            this.launchUiCheck();
         }
      }
      
      private var _moduleScriptLoadedRef:Dictionary;
      
      private function onScriptLoad(e:ResourceLoadedEvent) : void {
         var _loc5_:* = false;
         var _loc6_:* = true;
         var uiModule:UiModule = this._unInitializedModules[e.uri.tag];
         var moduleLoader:Loader = new Loader();
         this._moduleScriptLoadedRef[moduleLoader] = uiModule;
         var lc:LoaderContext = new LoaderContext(false,new ApplicationDomain(this._sharedDefinition));
         AirScanner.allowByteCodeExecution(lc,true);
         moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
         moduleLoader.loadBytes(e.resource as ByteArray,lc);
      }
      
      private function onModuleScriptLoaded(e:Event, uiModule:UiModule = null) : void {
         var _loc6_:* = true;
         var _loc7_:* = false;
         var l:Loader = LoaderInfo(e.target).loader;
         l.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onModuleScriptLoaded);
         if(!uiModule)
         {
            uiModule = this._moduleScriptLoadedRef[l];
         }
         delete this._loadingModule[uiModule];
         _log.trace("Load script " + uiModule.id + ", " + (this._moduleCount - this._scriptNum + 1) + "/" + this._moduleCount);
         uiModule.loader = l;
         uiModule.applicationDomain = l.contentLoaderInfo.applicationDomain;
         uiModule.mainClass = l.content;
         this._modules[uiModule.id] = uiModule;
         delete this._disabledModules[uiModule.id];
         Berilia.getInstance().handler.process(new ModuleLoadedMessage(uiModule.id));
         if(!--this._scriptNum)
         {
            this.launchUiCheck();
         }
      }
      
      private function onShortcutLoad(e:ResourceLoadedEvent) : void {
         var _loc14_:* = true;
         var _loc15_:* = false;
         var category:XML = null;
         var cat:ShortcutCategory = null;
         var permanent:* = false;
         var visible:* = false;
         var required:* = false;
         var holdKeys:* = false;
         var shortcut:XML = null;
         var shortcutsXml:XML = e.resource;
         for each(category in shortcutsXml..category)
         {
            cat = ShortcutCategory.create(category.@name,LangManager.getInstance().replaceKey(category.@description));
            for each(shortcut in category..shortcut)
            {
               if((!shortcut.@name) || (!shortcut.@name.toString().length))
               {
                  ErrorManager.addError("Le fichier de raccourci est mal formé, il manque la priopriété name dans le fichier " + e.uri);
                  return;
               }
               permanent = false;
               if((shortcut.@permanent) && (shortcut.@permanent == "true"))
               {
                  permanent = true;
               }
               visible = true;
               if((shortcut.@visible) && (shortcut.@visible == "false"))
               {
                  visible = false;
               }
               required = false;
               if((shortcut.@required) && (shortcut.@required == "true"))
               {
                  required = true;
               }
               holdKeys = false;
               if((shortcut.@holdKeys) && (shortcut.@holdKeys == "true"))
               {
                  holdKeys = true;
               }
            }
         }
      }
      
      private function onHashLoaded(e:ResourceLoadedEvent) : void {
         var _loc5_:* = true;
         var _loc6_:* = false;
         var file:XML = null;
         for each(file in e.resource..file)
         {
            this._modulesHashs[file.@name.toString()] = file.toString();
         }
      }
      
      private function onAllUiChecked(e:ResourceLoaderProgressEvent) : void {
         var module:UiModule;
         var url:String;
         var ui:UiData;
         while (true) {
             goto _label_1;
         };
         var _local_7 = _local_7;
         
     _label_1: 
         var uiDataList:Array = new Array();
         for each (module in this._unInitializedModules) {
             //unresolved jump
             var _local_6 = _local_6;
             for each (ui in module.uis) {
                 //unresolved jump
             };
         };
         this._unparsedXml = [];
         _loop_1:
         for (url in this._clearUi) {
             while (UiRenderManager.getInstance().clearCacheFromId(url), true) {
                 UiRenderManager.getInstance().setUiVersion(url, this._clearUi[url]);
                 goto _label_2;
             };
             
         _label_2: 
             if (uiDataList[url]){
                 while (this._unparsedXml.push(uiDataList[url]), true) {
                     continue _loop_1;
                 };
                 var _local_11 = _local_11;
             };
         };
         this._unparsedXmlCount = (this._unparsedXmlTotalCount = this._unparsedXml.length);
         while (this.parseNextXml(), true) {
             return;
         };
         return;
      }
      
      private function parseNextXml() : void {
         var _loc5_:* = true;
         var _loc6_:* = false;
         var uiData:UiData = null;
         var xmlParsor:XmlParsor = null;
         this._unparsedXmlCount = this._unparsedXml.length;
         if(this._unparsedXml.length)
         {
            if(this._parserAvaibleCount)
            {
               this._parserAvaibleCount--;
               uiData = this._unparsedXml.shift() as UiData;
               xmlParsor = new XmlParsor();
               xmlParsor.rootPath = uiData.module.rootPath;
               xmlParsor.addEventListener(Event.COMPLETE,this.onXmlParsed,false,0,true);
               xmlParsor.addEventListener(ParsingErrorEvent.ERROR,this.onXmlParsingError);
               xmlParsor.processFile(uiData.file);
            }
         }
         else
         {
            BindsManager.getInstance().checkBinds();
            Berilia.getInstance().handler.process(new AllUiXmlParsedMessage());
            if((!this._useSharedDefinition) || (this._sharedDefinition))
            {
               this.launchModule();
            }
            else
            {
               this._moduleLaunchWaitForSharedDefinition = true;
            }
         }
      }
      
      private function onXmlParsed(e:ParsorEvent) : void {
         var _loc4_:* = false;
         var _loc5_:* = true;
         if(e.uiDefinition)
         {
            e.uiDefinition.name = XmlParsor(e.target).url;
            UiRenderManager.getInstance().setUiDefinition(e.uiDefinition);
            Berilia.getInstance().handler.process(new UiXmlParsedMessage(e.uiDefinition.name));
         }
         this._parserAvaibleCount++;
         this.parseNextXml();
      }
      
      private function onXmlParsingError(e:ParsingErrorEvent) : void {
         var _loc2_:* = false;
         var _loc3_:* = true;
         Berilia.getInstance().handler.process(new UiXmlParsedErrorMessage(e.url,e.msg));
      }
      
      private function onUiLoaded(e:ResourceLoadedEvent) : void {
         var res:Array;
         var filePath:String;
         var modName:String;
         var templateUri:Uri;
         while (true) {
             goto _label_4;
             
         _label_1: 
             goto _label_3;
             
         _label_2: 
             goto _label_5;
         };
         
     _label_3: 
         goto _label_2;
         
     _label_4: 
         goto _label_1;
         var _local_13 = _local_13;
         
     _label_5: 
         if (this._resetState){
             return;
         };
         var uriPos:int = this._uiFiles.indexOf(e.uri);
         this._uiFiles.splice(this._uiFiles.indexOf(e.uri), 1);
         var mod:UiModule = this._unInitializedModules[e.uri.tag.mod];
         var base:String = e.uri.tag.base;
         var md5:String = ((!((this._versions[e.uri.uri] == null))) ? this._versions[e.uri.uri] : MD5.hash((e.resource as String)));
         var versionOk:Boolean = (md5 == UiRenderManager.getInstance().getUiVersion(e.uri.uri));
         if (!(versionOk)){
             while ((this._clearUi[e.uri.uri] = md5), true) {
                 goto _label_6;
             };
             var _local_12 = _local_12;
             
         _label_6: 
             if (e.uri.tag.template){
                 goto _label_8;
             };
         };
         
     _label_7: 
         this._versions[e.uri.uri] = md5;
         goto _label_9;
         
     _label_8: 
         this._clearUi[e.uri.tag.base] = this._versions[e.uri.tag.base];
         goto _label_7;
         
     _label_9: 
         var xml:String = (e.resource as String);
         while ((res = this._regImport.exec(xml))) {
             while (true) {
                 while ((filePath = LangManager.getInstance().replaceKey(res[1])), true) {
                     goto _label_10;
                 };
             };
             
         _label_10: 
             if (filePath.indexOf("mod://") != -1){
                 for (;;) {
                     //unresolved jump
                     continue;
                 };
             } else {
                 if ((((filePath.indexOf(":") == -1)) && ((filePath.indexOf("ui/Ankama_Common") == -1)))){
                     filePath = (mod.rootPath + filePath);
                 };
             };
             if (this._clearUi[filePath]){
                 goto _label_13;
                 
             _label_11: 
                 this._clearUi[base] = this._versions[base];
                 //unresolved jump
                 
             _label_12: 
                 goto _label_11;
                 
             _label_13: 
                 this._clearUi[e.uri.uri] = md5;
                 goto _label_12;
             } else {
                 if (!(this._uiLoaded[filePath])){
                     while (true) {
                         this._uiLoaded[filePath] = true;
                         //unresolved jump
                     };
                     var _local_15 = _local_15;
                     this._uiFileToLoad++;
                     goto _label_16;
                     
                 _label_14: 
                     templateUri.tag = {
                         "mod":mod.id,
                         "base":base,
                         "template":true
                     };
                     goto _label_18;
                     
                 _label_15: 
                     goto _label_14;
                     
                 _label_16: 
                     templateUri = new Uri(filePath);
                     goto _label_15;
                     
                 _label_17: 
                     this._uiLoader.load(templateUri, null, TxtAdapter);
                     continue;
                     
                 _label_18: 
                     goto _label_17;
                 };
             };
         };
         if (!(--this._uiFileToLoad)){
             while (this.onAllUiChecked(null), true) {
                 return;
             };
         };
         return;
      }
      
      private var _uiLoaded:Dictionary;
      
      private function searchDmFile(rootPath:File) : File {
         var _loc7_:* = false;
         var _loc8_:* = true;
         var file:File = null;
         var dm:File = null;
         if(rootPath.nativePath.indexOf(".svn") != -1)
         {
            return null;
         }
         var files:Array = rootPath.getDirectoryListing();
         for each(file in files)
         {
            if((!file.isDirectory) && (file.extension))
            {
               if(file.extension.toLowerCase() == "d2ui")
               {
                  return file;
               }
               if((!dm) && (file.extension.toLowerCase() == "dm"))
               {
                  dm = file;
               }
            }
         }
         if(dm)
         {
            return dm;
         }
         for each(file in files)
         {
            if(file.isDirectory)
            {
               dm = this.searchDmFile(file);
               if(dm)
               {
                  break;
               }
            }
         }
         return dm;
      }
      
      private function onSharedDefinitionLoad(e:ResourceLoadedEvent) : void {
         var _loc6_:* = false;
         var _loc7_:* = true;
         EnterFrameDispatcher.removeEventListener(this.timeOutFrameCount);
         var aswf:ASwf = e.resource as ASwf;
         this._sharedDefinition = aswf.applicationDomain;
         var sharedSecureComponent:Object = this._sharedDefinition.getDefinition("d2components::SecureComponent");
         sharedSecureComponent.init(SecureCenter.ACCESS_KEY,SecureCenter.unsecureContent,SecureCenter.secure,SecureCenter.unsecure,DescribeTypeCache.getVariables);
         var sharedReadOnlyData:Object = this._sharedDefinition.getDefinition("utils::ReadOnlyData");
         sharedReadOnlyData.init(SecureCenter.ACCESS_KEY,SecureCenter.unsecureContent,SecureCenter.secure,SecureCenter.unsecure);
         var directAccessObject:Object = this._sharedDefinition.getDefinition("utils::DirectAccessObject");
         directAccessObject.init(SecureCenter.ACCESS_KEY);
         SecureCenter.init(sharedSecureComponent,sharedReadOnlyData,directAccessObject);
         this._sharedDefinitionInstance = Object(aswf.content);
         this._loadModuleFunction = Object(aswf.content).loadModule;
         if(this._waitingInit)
         {
            this.init(this._filter,this._filterInclude);
         }
         if(this._moduleLaunchWaitForSharedDefinition)
         {
            this.launchModule();
         }
      }
      
      private var _loadModuleFunction:Function;
   }
}
