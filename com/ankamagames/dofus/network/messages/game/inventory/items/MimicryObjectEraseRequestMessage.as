﻿package com.ankamagames.dofus.network.messages.game.inventory.items
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class MimicryObjectEraseRequestMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6457;

        private var _isInitialized:Boolean = false;
        public var hostUID:uint = 0;
        public var hostPos:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6457);
        }

        public function initMimicryObjectEraseRequestMessage(hostUID:uint=0, hostPos:uint=0):MimicryObjectEraseRequestMessage
        {
            this.hostUID = hostUID;
            this.hostPos = hostPos;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.hostUID = 0;
            this.hostPos = 0;
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
            this.serializeAs_MimicryObjectEraseRequestMessage(output);
        }

        public function serializeAs_MimicryObjectEraseRequestMessage(output:ICustomDataOutput):void
        {
            if (this.hostUID < 0)
            {
                throw (new Error((("Forbidden value (" + this.hostUID) + ") on element hostUID.")));
            };
            output.writeVarInt(this.hostUID);
            if ((((this.hostPos < 0)) || ((this.hostPos > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.hostPos) + ") on element hostPos.")));
            };
            output.writeByte(this.hostPos);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_MimicryObjectEraseRequestMessage(input);
        }

        public function deserializeAs_MimicryObjectEraseRequestMessage(input:ICustomDataInput):void
        {
            this.hostUID = input.readVarUhInt();
            if (this.hostUID < 0)
            {
                throw (new Error((("Forbidden value (" + this.hostUID) + ") on element of MimicryObjectEraseRequestMessage.hostUID.")));
            };
            this.hostPos = input.readUnsignedByte();
            if ((((this.hostPos < 0)) || ((this.hostPos > 0xFF))))
            {
                throw (new Error((("Forbidden value (" + this.hostPos) + ") on element of MimicryObjectEraseRequestMessage.hostPos.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.items

