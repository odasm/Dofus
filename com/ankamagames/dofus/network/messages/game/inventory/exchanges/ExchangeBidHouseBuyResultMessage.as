﻿package com.ankamagames.dofus.network.messages.game.inventory.exchanges
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ExchangeBidHouseBuyResultMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 6272;

        private var _isInitialized:Boolean = false;
        public var uid:uint = 0;
        public var bought:Boolean = false;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (6272);
        }

        public function initExchangeBidHouseBuyResultMessage(uid:uint=0, bought:Boolean=false):ExchangeBidHouseBuyResultMessage
        {
            this.uid = uid;
            this.bought = bought;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.uid = 0;
            this.bought = false;
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
            this.serializeAs_ExchangeBidHouseBuyResultMessage(output);
        }

        public function serializeAs_ExchangeBidHouseBuyResultMessage(output:ICustomDataOutput):void
        {
            if (this.uid < 0)
            {
                throw (new Error((("Forbidden value (" + this.uid) + ") on element uid.")));
            };
            output.writeVarInt(this.uid);
            output.writeBoolean(this.bought);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ExchangeBidHouseBuyResultMessage(input);
        }

        public function deserializeAs_ExchangeBidHouseBuyResultMessage(input:ICustomDataInput):void
        {
            this.uid = input.readVarUhInt();
            if (this.uid < 0)
            {
                throw (new Error((("Forbidden value (" + this.uid) + ") on element of ExchangeBidHouseBuyResultMessage.uid.")));
            };
            this.bought = input.readBoolean();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.inventory.exchanges

