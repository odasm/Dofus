﻿package com.ankamagames.dofus.uiApi
{
    import com.ankamagames.berilia.interfaces.IApi;
    import com.ankamagames.berilia.types.data.UiModule;
    import com.ankamagames.jerakine.logger.Logger;
    import com.ankamagames.jerakine.logger.Log;
    import flash.utils.getQualifiedClassName;
    import com.ankamagames.dofus.kernel.Kernel;
    import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayEntitiesFrame;
    import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayInteractivesFrame;
    import com.ankamagames.dofus.logic.game.common.frames.SpellInventoryManagementFrame;
    import com.ankamagames.dofus.logic.game.common.frames.EmoticonFrame;
    import com.ankamagames.dofus.logic.game.roleplay.frames.ZaapFrame;
    import com.ankamagames.dofus.internalDatacenter.spells.SpellWrapper;
    import com.ankamagames.dofus.logic.game.common.managers.PlayedCharacterManager;
    import com.ankamagames.atouin.managers.EntitiesManager;
    import com.ankamagames.dofus.logic.game.roleplay.managers.RoleplayManager;
    import com.ankamagames.dofus.types.entities.AnimatedCharacter;
    import com.ankamagames.dofus.logic.game.roleplay.frames.RoleplayContextFrame;
    import com.ankamagames.jerakine.entities.interfaces.IEntity;
    import com.ankamagames.dofus.network.types.game.context.roleplay.GameRolePlayNamedActorInformations;

    [InstanciedApi]
    public class RoleplayApi implements IApi 
    {

        private var _module:UiModule;
        protected var _log:Logger;

        public function RoleplayApi()
        {
            this._log = Log.getLogger(getQualifiedClassName(RoleplayApi));
            super();
        }

        private function get roleplayEntitiesFrame():RoleplayEntitiesFrame
        {
            return ((Kernel.getWorker().getFrame(RoleplayEntitiesFrame) as RoleplayEntitiesFrame));
        }

        private function get roleplayInteractivesFrame():RoleplayInteractivesFrame
        {
            return ((Kernel.getWorker().getFrame(RoleplayInteractivesFrame) as RoleplayInteractivesFrame));
        }

        private function get spellInventoryManagementFrame():SpellInventoryManagementFrame
        {
            return ((Kernel.getWorker().getFrame(SpellInventoryManagementFrame) as SpellInventoryManagementFrame));
        }

        private function get roleplayEmoticonFrame():EmoticonFrame
        {
            return ((Kernel.getWorker().getFrame(EmoticonFrame) as EmoticonFrame));
        }

        private function get zaapFrame():ZaapFrame
        {
            return ((Kernel.getWorker().getFrame(ZaapFrame) as ZaapFrame));
        }

        [ApiData(name="module")]
        public function set module(value:UiModule):void
        {
            this._module = value;
        }

        [Trusted]
        public function destroy():void
        {
            this._module = null;
        }

        [Untrusted]
        public function getTotalFightOnCurrentMap():uint
        {
            return (this.roleplayEntitiesFrame.fightNumber);
        }

        [Untrusted]
        public function getSpellToForgetList():Array
        {
            var spell:SpellWrapper;
            var spellList:Array = new Array();
            for each (spell in PlayedCharacterManager.getInstance().spellsInventory)
            {
                if (spell.spellLevel > 1)
                {
                    spellList.push(spell);
                };
            };
            return (spellList);
        }

        [Untrusted]
        public function getEmotesList():Array
        {
            var emotes:Array = this.roleplayEmoticonFrame.emotesList;
            return (emotes);
        }

        [Untrusted]
        public function getUsableEmotesList():Array
        {
            return (this.roleplayEmoticonFrame.emotes);
        }

        [Untrusted]
        public function getSpawnMap():uint
        {
            return (this.zaapFrame.spawnMapId);
        }

        [Trusted]
        public function getEntitiesOnCell(cellId:int):Array
        {
            return (EntitiesManager.getInstance().getEntitiesOnCell(cellId));
        }

        [Trusted]
        public function getPlayersIdOnCurrentMap():Array
        {
            return (this.roleplayEntitiesFrame.playersId);
        }

        [Trusted]
        public function getPlayerIsInCurrentMap(playerId:int):Boolean
        {
            return (!((this.roleplayEntitiesFrame.playersId.indexOf(playerId) == -1)));
        }

        [Trusted]
        public function isUsingInteractive():Boolean
        {
            if (!(this.roleplayInteractivesFrame))
            {
                return (false);
            };
            return (this.roleplayInteractivesFrame.usingInteractive);
        }

        [Untrusted]
        public function getFight(id:int):Object
        {
            return (this.roleplayEntitiesFrame.fights[id]);
        }

        [Trusted]
        public function putEntityOnTop(entity:AnimatedCharacter):void
        {
            RoleplayManager.getInstance().putEntityOnTop(entity);
        }

        [Untrusted]
        public function getEntityInfos(entity:Object):Object
        {
            var roleplayContextFrame:RoleplayContextFrame = (Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame);
            return (roleplayContextFrame.entitiesFrame.getEntityInfos(entity.id));
        }

        [Untrusted]
        public function getEntityByName(name:String):Object
        {
            var entity:IEntity;
            var infos:GameRolePlayNamedActorInformations;
            var roleplayContextFrame:RoleplayContextFrame = (Kernel.getWorker().getFrame(RoleplayContextFrame) as RoleplayContextFrame);
            for each (entity in EntitiesManager.getInstance().entities)
            {
                infos = (roleplayContextFrame.entitiesFrame.getEntityInfos(entity.id) as GameRolePlayNamedActorInformations);
                if (((infos) && ((name == infos.name))))
                {
                    return (entity);
                };
            };
            return (null);
        }

        [Trusted]
        public function switchButtonWrappers(btnWrapper1:Object, btnWrapper2:Object):void
        {
            var indexT:int = btnWrapper2.position;
            var indexS:int = btnWrapper1.position;
            btnWrapper2.setPosition(indexS);
            btnWrapper1.setPosition(indexT);
        }

        [Trusted]
        public function setButtonWrapperActivation(btnWrapper:Object, active:Boolean):void
        {
            btnWrapper.active = active;
        }


    }
}//package com.ankamagames.dofus.uiApi

