﻿package com.ankamagames.dofus.logic.game.fight.steps
{
    import com.ankamagames.jerakine.sequencer.AbstractSequencable;
    import com.ankamagames.jerakine.sequencer.ISequencableListener;
    import com.ankamagames.dofus.logic.game.fight.managers.BuffManager;
    import com.ankamagames.dofus.logic.game.fight.fightEvents.FightEventsHelper;
    import com.ankamagames.dofus.logic.game.fight.types.FightEventEnum;
    import com.ankamagames.jerakine.sequencer.ISequencable;

    public class FightModifyEffectsDurationStep extends AbstractSequencable implements IFightStep, ISequencableListener 
    {

        private var _sourceId:int;
        private var _targetId:int;
        private var _delta:int;
        private var _virtualStep:IFightStep;

        public function FightModifyEffectsDurationStep(sourceId:int, targetId:int, delta:int)
        {
            this._sourceId = sourceId;
            this._targetId = targetId;
            this._delta = delta;
        }

        public function get stepType():String
        {
            return ("modifyEffectsDuration");
        }

        override public function start():void
        {
            BuffManager.getInstance().incrementDuration(this._targetId, this._delta, true, BuffManager.INCREMENT_MODE_TARGET);
            FightEventsHelper.sendFightEvent(FightEventEnum.FIGHTER_EFFECTS_MODIFY_DURATION, [this._sourceId, this._targetId, this._delta], this._targetId, castingSpellId);
            if (!(this._virtualStep))
            {
                executeCallbacks();
            }
            else
            {
                this._virtualStep.addListener(this);
                this._virtualStep.start();
            };
        }

        public function stepFinished(step:ISequencable, withTimout:Boolean=false):void
        {
            this._virtualStep.removeListener(this);
            executeCallbacks();
        }


    }
}//package com.ankamagames.dofus.logic.game.fight.steps

