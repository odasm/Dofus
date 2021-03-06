﻿package com.ankamagames.dofus.network.messages.game.guild
{
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.ankamagames.jerakine.network.INetworkMessage;
    import flash.utils.ByteArray;
    import com.ankamagames.jerakine.network.CustomDataWrapper;
    import com.ankamagames.jerakine.network.ICustomDataOutput;
    import com.ankamagames.jerakine.network.ICustomDataInput;

    [Trusted]
    public class ChallengeFightJoinRefusedMessage extends NetworkMessage implements INetworkMessage 
    {

        public static const protocolId:uint = 5908;

        private var _isInitialized:Boolean = false;
        public var playerId:uint = 0;
        public var reason:int = 0;


        override public function get isInitialized():Boolean
        {
            return (this._isInitialized);
        }

        override public function getMessageId():uint
        {
            return (5908);
        }

        public function initChallengeFightJoinRefusedMessage(playerId:uint=0, reason:int=0):ChallengeFightJoinRefusedMessage
        {
            this.playerId = playerId;
            this.reason = reason;
            this._isInitialized = true;
            return (this);
        }

        override public function reset():void
        {
            this.playerId = 0;
            this.reason = 0;
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
            this.serializeAs_ChallengeFightJoinRefusedMessage(output);
        }

        public function serializeAs_ChallengeFightJoinRefusedMessage(output:ICustomDataOutput):void
        {
            if (this.playerId < 0)
            {
                throw (new Error((("Forbidden value (" + this.playerId) + ") on element playerId.")));
            };
            output.writeVarInt(this.playerId);
            output.writeByte(this.reason);
        }

        public function deserialize(input:ICustomDataInput):void
        {
            this.deserializeAs_ChallengeFightJoinRefusedMessage(input);
        }

        public function deserializeAs_ChallengeFightJoinRefusedMessage(input:ICustomDataInput):void
        {
            this.playerId = input.readVarUhInt();
            if (this.playerId < 0)
            {
                throw (new Error((("Forbidden value (" + this.playerId) + ") on element of ChallengeFightJoinRefusedMessage.playerId.")));
            };
            this.reason = input.readByte();
        }


    }
}//package com.ankamagames.dofus.network.messages.game.guild

