﻿package com.ankamagames.dofus.network.messages.game.chat
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ChatAbstractClientMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 850;

        private var _isInitialized:Boolean = false;
        [Transient]
        public var content:String = "";


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (850);
        }

        public function initChatAbstractClientMessage(content:String=""):ChatAbstractClientMessage
        {
            this.content = content;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.content = "";
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
            this.serializeAs_ChatAbstractClientMessage(output);
        }

        public function serializeAs_ChatAbstractClientMessage(output:ICustomDataOutput):void
        {
            output.writeUTF(this.content);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ChatAbstractClientMessage(input);
        }

        public function deserializeAs_ChatAbstractClientMessage(input:ICustomDataInput):void
        {
            this.content = input.readUTF();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.chat

