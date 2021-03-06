﻿package com.ankamagames.dofus.network.messages.game.inventory.preset
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class InventoryPresetDeleteResultMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6173;

        private var _isInitialized:Boolean = false;
        public var presetId:uint = 0;
        public var code:uint = 2;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6173);
        }

        public function initInventoryPresetDeleteResultMessage(presetId:uint=0, code:uint=2):InventoryPresetDeleteResultMessage
        {
            this.presetId = presetId;
            this.code = code;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.presetId = 0;
            this.code = 2;
            this._isInitialized = false;
        }

        override public function pack(output:ICustomDataOutput):void
        {
            var data:ByteArray = new ByteArray();
            this.serialize(new CustomDataWrapper(data));
            writePacket(output, this.getMessageId(), data);
        }

        override public function unpack(input:ICustomDataInput, length:uint):void
        {
            this.deserialize(input);
        }

        public function serialize(output:ICustomDataOutput):void
        {
            this.serializeAs_InventoryPresetDeleteResultMessage(output);
        }

        public function serializeAs_InventoryPresetDeleteResultMessage(output:ICustomDataOutput):void
        {
            if (this.presetId < 0)
            {
                throw (new Error((("Forbidden value (" + this.presetId) + ") on element presetId.")));
            };
            output.writeByte(this.presetId);
            output.writeByte(this.code);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_InventoryPresetDeleteResultMessage(input);
        }

        public function deserializeAs_InventoryPresetDeleteResultMessage(input:ICustomDataInput):void
        {
            this.presetId = input.readByte();
            if (this.presetId < 0)
            {
                throw (new Error((("Forbidden value (" + this.presetId) + ") on element of InventoryPresetDeleteResultMessage.presetId.")));
            };
            this.code = input.readByte();
            if (this.code < 0)
            {
                throw (new Error((("Forbidden value (" + this.code) + ") on element of InventoryPresetDeleteResultMessage.code.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.preset

