﻿package com.ankamagames.dofus.network.types.game.look
{
    import com.ankamagames.jerakine.network.INetworkType;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    public class SubEntity implements INetworkType 
    {

        public static const protocolId:uint = 54;

        public var bindingPointCategory:uint = 0;
        public var bindingPointIndex:uint = 0;
        public var subEntityLook:EntityLook;

        public function SubEntity()
        {
            this.subEntityLook = new EntityLook();
            super();
        }

        public function getTypeId():uint
        {
            return (54);
        }

        public function initSubEntity(bindingPointCategory:uint=0, bindingPointIndex:uint=0, subEntityLook:EntityLook=null):SubEntity
        {
            this.bindingPointCategory = bindingPointCategory;
            this.bindingPointIndex = bindingPointIndex;
            this.subEntityLook = subEntityLook;
            return (this);
        }

        public function reset():void
        {
            this.bindingPointCategory = 0;
            this.bindingPointIndex = 0;
            this.subEntityLook = new EntityLook();
        }

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_SubEntity(output);
        }

        public function serializeAs_SubEntity(output:ICustomDataOutput):void
        {
            output.writeByte(this.bindingPointCategory);
            if (this.bindingPointIndex < 0)
            {
                throw (new Error((("Forbidden value (" + this.bindingPointIndex) + ") on element bindingPointIndex.")));
            };
            output.writeByte(this.bindingPointIndex);
            this.subEntityLook.serializeAs_EntityLook(output);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_SubEntity(input);
        }

        public function deserializeAs_SubEntity(input:ICustomDataInput):void
        {
            this.bindingPointCategory = input.readByte();
            if (this.bindingPointCategory < 0)
            {
                throw (new Error((("Forbidden value (" + this.bindingPointCategory) + ") on element of SubEntity.bindingPointCategory.")));
            };
            this.bindingPointIndex = input.readByte();
            if (this.bindingPointIndex < 0)
            {
                throw (new Error((("Forbidden value (" + this.bindingPointIndex) + ") on element of SubEntity.bindingPointIndex.")));
            };
            this.subEntityLook = new EntityLook();
            this.subEntityLook.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.types.game.look

