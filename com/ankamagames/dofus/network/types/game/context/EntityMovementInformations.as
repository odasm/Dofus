﻿package com.ankamagames.dofus.network.types.game.context
{
    import com.ankamagames.jerakine.network.INetworkType;
    import __AS3__.vec.Vector;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;
    import __AS3__.vec.*;

    [Trusted]
    public class EntityMovementInformations implements INetworkType 
    {

        public static const protocolId:uint = 63;

        public var id:int = 0;
        public var steps:Vector.<int>;

        public function EntityMovementInformations()
        {
            this.steps = new Vector.<int>();
            super();
        }

        public function getTypeId():uint
        {
            return (63);
        }

        public function initEntityMovementInformations(id:int=0, steps:Vector.<int>=null):EntityMovementInformations
        {
            this.id = id;
            this.steps = steps;
            return (this);
        }

        public function reset():void
        {
            this.id = 0;
            this.steps = new Vector.<int>();
        }

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_EntityMovementInformations(output);
        }

        public function serializeAs_EntityMovementInformations(output:ICustomDataOutput):void
        {
            output.writeInt(this.id);
            output.writeShort(this.steps.length);
            var _i2:uint;
            while (_i2 < this.steps.length)
            {
                output.writeByte(this.steps[_i2]);
                _i2++;
            };
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_EntityMovementInformations(input);
        }

        public function deserializeAs_EntityMovementInformations(input:ICustomDataInput):void
        {
            var _val2:int;
            this.id = input.readInt();
            var _stepsLen:uint = input.readUnsignedShort();
            var _i2:uint;
            while (_i2 < _stepsLen)
            {
                _val2 = input.readByte();
                this.steps.push(_val2);
                _i2++;
            };
        }


    }
}//package com.ankamagames.dofus.network.types.game.context

