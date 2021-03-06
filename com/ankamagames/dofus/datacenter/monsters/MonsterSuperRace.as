﻿package com.ankamagames.dofus.datacenter.monsters
{
    import com.ankamagames.jerakine.interfaces.IDataCenter;
    import com.ankamagames.jerakine.data.GameData;
    import com.ankamagames.jerakine.data.I18n;

    public class MonsterSuperRace implements IDataCenter 
    {

        public static const MODULE:String = "MonsterSuperRaces";

        public var id:int;
        public var nameId:uint;
        private var _name:String;


        public static function getMonsterSuperRaceById(id:uint):MonsterSuperRace
        {
            return ((GameData.getObject(MODULE, id) as MonsterSuperRace));
        }

        public static function getMonsterSuperRaces():Array
        {
            return (GameData.getObjects(MODULE));
        }


        public function get name():String
        {
            if (!(this._name))
            {
                this._name = I18n.getText(this.nameId);
            };
            return (this._name);
        }


    }
}//package com.ankamagames.dofus.datacenter.monsters

