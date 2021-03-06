﻿package com.ankamagames.dofus.network.messages.game.context
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import com.ankamagames.dofus.network.types.game.look.EntityLook;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class GameContextRefreshEntityLookMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5637;

        private var _isInitialized:Boolean = false;
        public var id:int = 0;
        public var look:EntityLook;

        public function GameContextRefreshEntityLookMessage()
        {
            this.look = new EntityLook();
            super();
        }

        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5637);
        }

        public function initGameContextRefreshEntityLookMessage(id:int=0, look:EntityLook=null):GameContextRefreshEntityLookMessage
        {
            this.id = id;
            this.look = look;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.id = 0;
            this.look = new EntityLook();
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
            this.serializeAs_GameContextRefreshEntityLookMessage(output);
        }

        public function serializeAs_GameContextRefreshEntityLookMessage(output:ICustomDataOutput):void
        {
            output.writeInt(this.id);
            this.look.serializeAs_EntityLook(output);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_GameContextRefreshEntityLookMessage(input);
        }

        public function deserializeAs_GameContextRefreshEntityLookMessage(input:ICustomDataInput):void
        {
            this.id = input.readInt();
            this.look = new EntityLook();
            this.look.deserialize(input);
        }


    }
}//package com.ankamagames.dofus.network.messages.game.context

