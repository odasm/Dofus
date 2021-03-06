﻿package com.ankamagames.dofus.network.types.game.context.roleplay.treasureHunt
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class TreasureHuntStepFollowDirection extends TreasureHuntStep implements INetworkType 
    {

        public static const protocolId:uint = 468;

        public var direction:uint = 1;
        public var mapCount:uint = 0;


        override public function getTypeId():uint
        {
            return (468);
        }

        public function initTreasureHuntStepFollowDirection(direction:uint=1, mapCount:uint=0):TreasureHuntStepFollowDirection
        {
            this.direction = direction;
            this.mapCount = mapCount;
            return (this);
        }

        override public function reset():void
        {
            this.direction = 1;
            this.mapCount = 0;
        }

        override public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_TreasureHuntStepFollowDirection(output);
        }

        public function serializeAs_TreasureHuntStepFollowDirection(output:ICustomDataOutput):void
        {
            super.serializeAs_TreasureHuntStep(output);
            output.writeByte(this.direction);
            if (this.mapCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.mapCount) + ") on element mapCount.")));
            };
            output.writeVarShort(this.mapCount);
        }

        override public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_TreasureHuntStepFollowDirection(input);
        }

        public function deserializeAs_TreasureHuntStepFollowDirection(input:ICustomDataInput):void
        {
            super.deserialize(input);
            this.direction = input.readByte();
            if (this.direction < 0)
            {
                throw (new Error((("Forbidden value (" + this.direction) + ") on element of TreasureHuntStepFollowDirection.direction.")));
            };
            this.mapCount = input.readVarUhShort();
            if (this.mapCount < 0)
            {
                throw (new Error((("Forbidden value (" + this.mapCount) + ") on element of TreasureHuntStepFollowDirection.mapCount.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.types.game.context.roleplay.treasureHunt

