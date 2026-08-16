using System;

namespace AnantaTestGameServer.BehaviorTreeEngine
{
    // ================================================================
    // INVERTER — flips Success↔Failure, passes Running through
    // ================================================================
    public class BTInverter : BTNode
    {
        public BTNode Child { get; }

        public BTInverter(BTNode child)
        {
            Child = child;
            Name = "Inverter";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            var status = Child.Evaluate(ctx);
            return status switch
            {
                TaskStatus.Success => TaskStatus.Failure,
                TaskStatus.Failure => TaskStatus.Success,
                _ => TaskStatus.Running,
            };
        }

        public override void Reset()
        {
            Child.Reset();
        }
    }

    // ================================================================
    // COOLDOWN — blocks re-execution for N seconds after success
    // Mirrors UtilityCalculator.cooldown field
    // ================================================================
    public class BTCooldown : BTNode
    {
        public BTNode Child { get; }
        public float CooldownSeconds { get; set; }
        private DateTime _lastSuccess = DateTime.MinValue;

        public BTCooldown(BTNode child, float cooldownSeconds)
        {
            Child = child;
            CooldownSeconds = cooldownSeconds;
            Name = $"Cooldown({cooldownSeconds}s)";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            if ((ctx.Now - _lastSuccess).TotalSeconds < CooldownSeconds)
            {
                return TaskStatus.Failure; // still on cooldown
            }

            var status = Child.Evaluate(ctx);

            if (status == TaskStatus.Success)
            {
                _lastSuccess = ctx.Now;
            }

            return status;
        }

        public override void Reset()
        {
            Child.Reset();
        }
    }

    // ================================================================
    // UTILITY CALCULATOR — dynamic score provider for UtilitySelector
    // Wraps a child node and provides a utility score based on context.
    // Mirrors DLL's UtilityCalculator abstract class.
    // ================================================================
    public class BTUtilityCalculator : BTNode
    {
        public BTNode Child { get; }
        public float BaseScore { get; set; }
        private Func<BTContext, float> _scoreFunc;

        /// <summary>
        /// Create with a static score (constant utility).
        /// </summary>
        public BTUtilityCalculator(BTNode child, float baseScore)
        {
            Child = child;
            BaseScore = baseScore;
            Name = $"Utility({baseScore})";
        }

        /// <summary>
        /// Create with a dynamic scoring function.
        /// </summary>
        public BTUtilityCalculator(BTNode child, Func<BTContext, float> scoreFunc)
        {
            Child = child;
            _scoreFunc = scoreFunc;
            BaseScore = 0;
            Name = "Utility(dynamic)";
        }

        /// <summary>
        /// Calculate the current utility score for this branch.
        /// Called by BTUtilitySelector during evaluation.
        /// </summary>
        public float GetUtility(BTContext ctx)
        {
            if (_scoreFunc != null)
                return _scoreFunc(ctx);
            return BaseScore;
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            return Child.Evaluate(ctx);
        }

        public override void Reset()
        {
            Child.Reset();
        }
    }

    // ================================================================
    // REPEATER — repeats child N times or until failure
    // ================================================================
    public class BTRepeater : BTNode
    {
        public BTNode Child { get; }
        public int MaxRepeats { get; set; }
        private int _currentRepeat = 0;

        public BTRepeater(BTNode child, int maxRepeats = -1)
        {
            Child = child;
            MaxRepeats = maxRepeats; // -1 = infinite
            Name = $"Repeater({(maxRepeats < 0 ? "∞" : maxRepeats.ToString())})";
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            var status = Child.Evaluate(ctx);

            if (status == TaskStatus.Failure)
            {
                _currentRepeat = 0;
                return TaskStatus.Failure;
            }

            if (status == TaskStatus.Running)
                return TaskStatus.Running;

            // Success — check if we should repeat
            _currentRepeat++;
            if (MaxRepeats > 0 && _currentRepeat >= MaxRepeats)
            {
                _currentRepeat = 0;
                return TaskStatus.Success;
            }

            return TaskStatus.Running; // keep repeating
        }

        public override void Reset()
        {
            _currentRepeat = 0;
            Child.Reset();
        }
    }
}
