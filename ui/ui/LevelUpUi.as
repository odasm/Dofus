﻿package ui
{
    import d2api.SystemApi;
    import d2api.TimeApi;
    import d2api.UiApi;
    import d2api.PlayedCharacterApi;
    import d2api.SoundApi;
    import d2components.Slot;
    import d2components.ButtonContainer;
    import d2components.Label;
    import d2components.Texture;
    import d2components.EntityDisplayer;
    import d2utils.ItemTooltipSettings;
    import d2actions.*;
    import d2hooks.*;

    public class LevelUpUi 
    {

        public var sysApi:SystemApi;
        public var timeApi:TimeApi;
        public var uiApi:UiApi;
        public var playerApi:PlayedCharacterApi;
        public var soundApi:SoundApi;
        public var spellSlot:Slot;
        public var btn_close:ButtonContainer;
        public var lbl_lifeStatPoints:Label;
        public var lbl_spellStatPoints:Label;
        public var lbl_caracStatPoints:Label;
        public var lbl_spell:Label;
        public var lbl_newLevel:Label;
        public var tx_spellSlotEffect:Texture;
        public var ed_player:EntityDisplayer;
        private var _assetsUri:Object;


        public function main(pParam:Object):void
        {
            this.uiApi.addComponentHook(this.spellSlot, "onRollOver");
            this.uiApi.addComponentHook(this.spellSlot, "onRollOut");
            this.uiApi.addShortcutHook("validUi", this.onShortcut);
            this.uiApi.addShortcutHook("closeUi", this.onShortcut);
            this._assetsUri = this.uiApi.me().getConstant("assets");
            var playerInfos:Object = this.playerApi.getPlayedCharacterInfo();
            var playerLook:Object = playerInfos.entityLook;
            playerLook.setBone(1);
            this.ed_player.animation = ("AnimEmoteInterface_" + ((playerInfos.sex) ? "1" : "0"));
            this.ed_player.look = playerLook;
            this.lbl_newLevel.text = this.uiApi.getText("ui.levelUp.TitleLevel", pParam.newLevel);
            this.lbl_lifeStatPoints.text = ("+ " + pParam.caracPointEarned);
            this.lbl_spellStatPoints.text = ("+ " + pParam.spellPointEarned);
            this.lbl_caracStatPoints.text = ("+ " + pParam.caracPointEarned);
            this.tx_spellSlotEffect["playOnce"] = true;
            this.tx_spellSlotEffect.uri = this.uiApi.createUri((this._assetsUri + "levelUp_tx_animPaillette"));
            this.spellSlot.allowDrag = false;
            this.spellSlot.data = pParam.newSpell;
            if (pParam.spellObtained)
            {
                this.lbl_spell.text = this.uiApi.getText("ui.levelUp.newSpell");
                this.tx_spellSlotEffect.gotoAndPlay = "1";
            }
            else
            {
                this.lbl_spell.text = ((this.uiApi.getText("ui.levelUp.nextSpell") + " ") + this.uiApi.getText("ui.levelUp.nextSpellLevel", pParam.levelSpellObtention));
            };
        }

        public function unload():void
        {
        }

        public function onRelease(target:Object):void
        {
            switch (target)
            {
                case this.btn_close:
                    this.uiApi.unloadUi(this.uiApi.me().name);
                    break;
            };
        }

        public function onRollOver(target:Object):void
        {
            var _local_2:ItemTooltipSettings;
            switch (target)
            {
                case this.spellSlot:
                    if (!(target.data))
                    {
                        return;
                    };
                    _local_2 = (this.sysApi.getData("itemTooltipSettings", true) as ItemTooltipSettings);
                    this.uiApi.showTooltip(target.data, target, false, "standard", 3, 3, 0, null, null, _local_2);
                    break;
            };
        }

        public function onRollOut(target:Object):void
        {
            switch (target)
            {
                case this.spellSlot:
                    this.uiApi.hideTooltip();
                    break;
            };
        }

        public function onShortcut(s:String):Boolean
        {
            switch (s)
            {
                case "validUi":
                case "closeUi":
                    this.uiApi.unloadUi(this.uiApi.me().name);
                    return (true);
            };
            return (false);
        }


    }
}//package ui

