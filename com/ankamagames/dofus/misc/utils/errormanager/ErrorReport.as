﻿package com.ankamagames.dofus.misc.utils.errormanager
{
    import com.ankamagames.jerakine.logger.targets.TemporaryBufferTarget;
    import com.ankamagames.dofus.logic.game.fight.frames.FightContextFrame;
    import flash.display.BitmapData;
    import by.blooddy.crypto.Base64;
    import by.blooddy.crypto.image.JPEGEncoder;
    import flash.filesystem.File;
    import com.ankamagames.jerakine.utils.system.AirScanner;
    import flash.events.Event;
    import flash.filesystem.FileStream;
    import com.ankamagames.jerakine.utils.system.SystemPopupUI;
    import flash.filesystem.FileMode;
    import flash.net.URLRequest;
    import flash.net.URLRequestMethod;
    import flash.utils.ByteArray;
    import flash.net.URLVariables;
    import flash.net.URLLoader;
    import flash.net.navigateToURL;
    import com.ankamagames.dofus.kernel.Kernel;

    public class ErrorReport 
    {

        private static var _htmlTemplate:Class = ErrorReport__htmlTemplate;
        private static var ONLINE_REPORT_PLATEFORM:String = "http://utils.dofus.lan/bugs/";
        private static var ONLINE_REPORT_SERVICE:String = (ONLINE_REPORT_PLATEFORM + "makeReport.php");

        private var _reportData:Object;
        private var _logBuffer:TemporaryBufferTarget;
        private var _htmlReport:String = "";
        private var _fightFrame:FightContextFrame;

        public function ErrorReport(reportInfo:Object, logBuffer:TemporaryBufferTarget)
        {
            this._logBuffer = logBuffer;
            this._reportData = reportInfo;
        }

        private function makeHtmlReport():String
        {
            var template:String;
            var key:String;
            if (this._htmlReport == "")
            {
                template = new _htmlTemplate();
                if (((this._reportData.screenshot) && ((this._reportData.screenshot is BitmapData))))
                {
                    this._reportData.screenshot = Base64.encode(JPEGEncoder.encode(this._reportData.screenshot, 80));
                };
                if (((this._reportData.stacktrace) && ((this._reportData.stacktrace is String))))
                {
                    this._reportData.stacktrace = String(this._reportData.stacktrace).replace(/</g, "&lt;").replace(/>/g, "&gt;");
                };
                for (key in this._reportData)
                {
                    template = template.replace((("{{" + key) + "}}"), this._reportData[key]);
                };
                this._htmlReport = template;
            };
            return (this._htmlReport);
        }

        public function saveReport():void
        {
            var date:Date = new Date();
            var fileName:String = (((((((((((("dofus_bug_report_" + date.date) + "-") + (date.month + 1)) + "-") + date.fullYear) + "_") + date.hours) + "h") + date.minutes) + "m") + date.seconds) + "s.html");
            var file:File = File.desktopDirectory.resolvePath(fileName);
            if (!(AirScanner.hasAir()))
            {
                file.save(this.makeHtmlReport(), fileName);
            }
            else
            {
                file.addEventListener(Event.SELECT, this.onFileSelected);
                file.browseForSave("Save report");
            };
        }

        private function onFileSelected(e:Event):void
        {
            var fs:FileStream;
            var popup:SystemPopupUI;
            try
            {
                fs = new FileStream();
                fs.open((e.target as File), FileMode.WRITE);
                fs.writeUTFBytes(this.makeHtmlReport());
                fs.close();
            }
            catch(err:Error)
            {
                popup = new SystemPopupUI("ReportSaveFail");
                popup.title = "Error";
                popup.content = ("An error occurred during report saving :\n" + err.message);
                popup.show();
            };
        }

        public function sendReport():void
        {
            var ur:URLRequest = new URLRequest(ONLINE_REPORT_SERVICE);
            ur.method = URLRequestMethod.POST;
            var reportRawData:ByteArray = new ByteArray();
            reportRawData.writeUTFBytes(this.makeHtmlReport());
            ur.data = new URLVariables();
            URLVariables(ur.data).userName = File.documentsDirectory.nativePath.split(File.separator)[2];
            URLVariables(ur.data).htmlContent = Base64.encode(reportRawData);
            var urlLoader:URLLoader = new URLLoader(ur);
            urlLoader.addEventListener(Event.COMPLETE, this.sendReportComplete);
        }

        private function sendReportComplete(e:Event):void
        {
            var _local_3:SystemPopupUI;
            var response:String = e.currentTarget.data;
            if (response.charAt(0) == "0")
            {
                navigateToURL(new URLRequest((ONLINE_REPORT_PLATEFORM + response.substr(2))));
            }
            else
            {
                _local_3 = new SystemPopupUI(("exception" + Math.random()));
                _local_3.width = 300;
                _local_3.centerContent = false;
                _local_3.title = "Error";
                _local_3.content = response.substr(2);
                _local_3.buttons = [{
                    "label":"OK",
                    "callback":trace
                }];
                _local_3.show();
                if (!(AirScanner.hasAir()))
                {
                    _local_3.scaleX = (800 / 0x0500);
                    _local_3.scaleY = (600 / 0x0400);
                };
            };
            (e.currentTarget as URLLoader).removeEventListener(Event.COMPLETE, this.sendReportComplete);
        }

        private function getFightFrame():FightContextFrame
        {
            if (this._fightFrame == null)
            {
                this._fightFrame = (Kernel.getWorker().getFrame(FightContextFrame) as FightContextFrame);
            };
            return (this._fightFrame);
        }


    }
}//package com.ankamagames.dofus.misc.utils.errormanager

