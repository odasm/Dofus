﻿package com.ankamagames.dofus.network.types.game.context.fight
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class FightResultFighterListEntry extends FightResultListEntry implements INetworkType 
    {

        public static const protocolId:uint = 189;

        public var id:int = 0;
        public var alive:Boolean = false;


        override public function getTypeId():uint
        {
            return (189);
        }

        public function initFightResultFighterListEntry(outcome:uint=0, wave:uint=0, rewards:FightLoot=null, id:int=0, alive:Boolean=false):FightResultFighterListEntry
        {
            super.initFightResultListEntry(outcome, wave, rewards);
            this.id = id;
            this.alive = alive;
            return (this);
        }

        override public function reset():void
        {
            super.reset();
            this.id = 0;
            this.alive = false;
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_FightResultFighterListEntry(output);
        }

        public function serializeAs_FightResultFighterListEntry(output:ICustomDataOutput):void
        {
            super.serializeAs_FightResultListEntry(output);
            output.writeInt(this.id);
            output.writeBoolean(this.alive);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_FightResultFighterListEntry(input);
        }

        public function deserializeAs_FightResultFighterListEntry(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.id = input.readInt();
            this.alive = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.fight

