﻿package com.ankamagames.dofus.network.messages.game.inventory.exchanges
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ExchangeStartOkMulticraftCustomerMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5817;

        private var _isInitialized:Boolean = false;
        public var maxCase:uint = 0;
        public var skillId:uint = 0;
        public var crafterJobLevel:uint = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5817);
        }

        public function initExchangeStartOkMulticraftCustomerMessage(maxCase:uint=0, skillId:uint=0, crafterJobLevel:uint=0):ExchangeStartOkMulticraftCustomerMessage
        {
            this.maxCase = maxCase;
            this.skillId = skillId;
            this.crafterJobLevel = crafterJobLevel;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.maxCase = 0;
            this.skillId = 0;
            this.crafterJobLevel = 0;
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
            this.serializeAs_ExchangeStartOkMulticraftCustomerMessage(output);
        }

        public function serializeAs_ExchangeStartOkMulticraftCustomerMessage(output:ICustomDataOutput):void
        {
            if (this.maxCase < 0)
            {
                throw (new Error((("Forbidden value (" + this.maxCase) + ") on element maxCase.")));
            };
            output.writeByte(this.maxCase);
            if (this.skillId < 0)
            {
                throw (new Error((("Forbidden value (" + this.skillId) + ") on element skillId.")));
            };
            output.writeVarInt(this.skillId);
            if (this.crafterJobLevel < 0)
            {
                throw (new Error((("Forbidden value (" + this.crafterJobLevel) + ") on element crafterJobLevel.")));
            };
            output.writeByte(this.crafterJobLevel);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ExchangeStartOkMulticraftCustomerMessage(input);
        }

        public function deserializeAs_ExchangeStartOkMulticraftCustomerMessage(input:ICustomDataInput):void
        {
            this.maxCase = input.readByte();
            if (this.maxCase < 0)
            {
                throw (new Error((("Forbidden value (" + this.maxCase) + ") on element of ExchangeStartOkMulticraftCustomerMessage.maxCase.")));
            };
            this.skillId = input.readVarUhInt();
            if (this.skillId < 0)
            {
                throw (new Error((("Forbidden value (" + this.skillId) + ") on element of ExchangeStartOkMulticraftCustomerMessage.skillId.")));
            };
            this.crafterJobLevel = input.readByte();
            if (this.crafterJobLevel < 0)
            {
                throw (new Error((("Forbidden value (" + this.crafterJobLevel) + ") on element of ExchangeStartOkMulticraftCustomerMessage.crafterJobLevel.")));
            };
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.exchanges

