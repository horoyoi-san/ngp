using System;
using System.Collections.Generic;
using System.Linq;

namespace AnantaTestGameServer.BehaviorTreeEngine
{
    // ================================================================
    // SELECTOR — OR logic: tries children until one succeeds
    // Mirrors BehaviorAI.Node.Composite (selector pattern)
    // ================================================================
    public class BTSelector : BTNode
    {
        public List<BTNode> Children { get; } = new();
        private int _currentIndex = 0;

        public BTSelector(params BTNode[] children)
        {
            Children.AddRange(children);
            Name = "Selector";
        }

        public BTSelector Add(BTNode child)
        {
            Children.Add(child);
            return this;
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            while (_currentIndex < Children.Count)
            {
                var status = Children[_currentIndex].Evaluate(ctx);

                switch (status)
                {
                    case TaskStatus.Success:
                        _currentIndex = 0;
                        return TaskStatus.Success;

                    case TaskStatus.Running:
                        return TaskStatus.Running;

                    case TaskStatus.Failure:
                        _currentIndex++;
                        break;
                }
            }

            _currentIndex = 0;
            return TaskStatus.Failure;
        }

        public override void Reset()
        {
            _currentIndex = 0;
            foreach (var child in Children)
                child.Reset();
        }
    }

    // ================================================================
    // SEQUENCE — AND logic: runs all children in order, fails if any fails
    // Mirrors BehaviorAI.Node.Composite (sequence pattern)
    // ================================================================
    public class BTSequence : BTNode
    {
        public List<BTNode> Children { get; } = new();
        private int _currentIndex = 0;

        public BTSequence(params BTNode[] children)
        {
            Children.AddRange(children);
            Name = "Sequence";
        }

        public BTSequence Add(BTNode child)
        {
            Children.Add(child);
            return this;
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            while (_currentIndex < Children.Count)
            {
                var status = Children[_currentIndex].Evaluate(ctx);

                switch (status)
                {
                    case TaskStatus.Failure:
                        _currentIndex = 0;
                        return TaskStatus.Failure;

                    case TaskStatus.Running:
                        return TaskStatus.Running;

                    case TaskStatus.Success:
                        _currentIndex++;
                        break;
                }
            }

            _currentIndex = 0;
            return TaskStatus.Success;
        }

        public override void Reset()
        {
            _currentIndex = 0;
            foreach (var child in Children)
                child.Reset();
        }
    }

    // ================================================================
    // UTILITY SELECTOR — Score-based selection (mirrors DLL UtilitySelector)
    // Evaluates all children with BTUtilityCalculator decorators,
    // picks the one with the highest utility score.
    // Reevaluates every tick — can switch tasks if a higher-scoring
    // option becomes available.
    // ================================================================
    public class BTUtilitySelector : BTNode
    {
        public List<ScoredBranch> Branches { get; } = new();
        private BTNode _currentBranch = null;

        /// <summary>
        /// Minimum score difference to switch from current task to a new one.
        /// Prevents flip-flopping between similar-scored branches.
        /// Mirrors DLL's changingTaskThreshold.
        /// </summary>
        public float SwitchThreshold { get; set; } = 5f;

        /// <summary>
        /// Minimum score to consider a branch at all.
        /// Mirrors DLL's consideringUtilityThreshold.
        /// </summary>
        public float ConsiderThreshold { get; set; } = 0.1f;

        public BTUtilitySelector(params ScoredBranch[] branches)
        {
            Branches.AddRange(branches);
            Name = "UtilitySelector";
        }

        public BTUtilitySelector Add(float score, BTNode node)
        {
            Branches.Add(new ScoredBranch(score, node));
            return this;
        }

        protected override TaskStatus OnUpdate(BTContext ctx)
        {
            // Score all branches (utility evaluation)
            float bestScore = 0;
            BTNode bestBranch = null;

            foreach (var branch in Branches)
            {
                // If the branch has a UtilityCalculator, use dynamic scoring
                float score = branch.BaseScore;
                if (branch.Node is BTUtilityCalculator calc)
                {
                    score = calc.GetUtility(ctx);
                }

                if (score >= ConsiderThreshold && score > bestScore)
                {
                    bestScore = score;
                    bestBranch = branch.Node;
                }
            }

            if (bestBranch == null)
            {
                // No branch scored above threshold
                _currentBranch?.Reset();
                _currentBranch = null;
                return TaskStatus.Failure;
            }

            // Check if we should switch tasks
            if (_currentBranch != null && _currentBranch != bestBranch)
            {
                // Find current branch's score
                float currentScore = 0;
                foreach (var branch in Branches)
                {
                    if (branch.Node == _currentBranch)
                    {
                        currentScore = branch.BaseScore;
                        if (branch.Node is BTUtilityCalculator calc)
                            currentScore = calc.GetUtility(ctx);
                        break;
                    }
                }

                // Only switch if new score is significantly better
                if (bestScore - currentScore < SwitchThreshold)
                {
                    bestBranch = _currentBranch; // keep current
                }
                else
                {
                    _currentBranch.Reset(); // abort current task
                }
            }

            _currentBranch = bestBranch;
            var status = _currentBranch.Evaluate(ctx);

            if (status != TaskStatus.Running)
            {
                _currentBranch = null;
            }

            return status;
        }

        public override void Reset()
        {
            _currentBranch?.Reset();
            _currentBranch = null;
            foreach (var branch in Branches)
                branch.Node.Reset();
        }
    }

    /// <summary>
    /// A branch in a UtilitySelector with a base utility score.
    /// </summary>
    public class ScoredBranch
    {
        public float BaseScore;
        public BTNode Node;

        public ScoredBranch(float score, BTNode node)
        {
            BaseScore = score;
            Node = node;
        }
    }
}
