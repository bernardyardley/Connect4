#nullable enable
using Connect4GameEngine;
using Godot;
using System;
using Connect4Node = MctsEngine.MctsNode<Connect4GameEngine.Connect4GameState, int>;

public partial class AiWrapper(int iterations, double temperature) : Node
{
    [Signal]
    public delegate void MoveCalculatedEventHandler(int move);
    public Connect4Bot MctsBot { get; private set; } = new Connect4Bot(iterations, temperature);
    public Connect4Node? RootNode { get; private set; }

    public bool GameOver => RootNode != null && RootNode.GameState.GameOver;

    public int Winner
    {
        get
        {
            if (RootNode == null)
                throw new InvalidOperationException("RootNode is null.");
            if (!RootNode.GameState.GameOver)
                throw new InvalidOperationException("Game is not over.");
            if (RootNode.GameState.IsWon)
                return -RootNode.GameState.NextPlayer;
            else
                return 0; // Draw
        }
    }

    public void GetFirstMove()
    {
        if (RootNode != null)
            throw new InvalidOperationException("RootNode must be null to get first move.");

        // Create initial game state
        var gameState = new Connect4GameState();
        var node = new Connect4Node(gameState);
        // Get the best move from MCTS and call this our root node
        GetBestMoveAsync(node);
    }

    public void GetBestMoveAsync(Connect4Node node)
    {
        // Run MCTS in a separate thread to avoid blocking the main thread
        System.Threading.Tasks.Task.Run(() =>
        {
            RootNode = MctsBot.CalculateBestResponse(node);
            // Marshal signal emission to the main thread using CallDeferred
            CallDeferred("emit_signal", SignalName.MoveCalculated, RootNode.Move);
        });
    }

    public void GetResponse(int playerMove)
    {
        if (RootNode == null)
        {
            // The player is starting first
            var gameState = new Connect4GameState().ApplyMove(playerMove);
            var node = new Connect4Node(gameState);
            GetBestMoveAsync(node);
            return;
        }

        // Find the child node that corresponds to the player's move
        foreach (var child in RootNode.Children)
        {
            if (child.Move == playerMove)
            {
                // If the game is over after the player's move, update the root and return
                if (child.GameState.GameOver)
                {
                    RootNode = child;
                    return;
                }
                // Remove the child's parent reference to free memory
                child.RemoveParentReference();
                // Update the root node to the best response to this child
                GetBestMoveAsync(child);
                return;
            }
        }

        // If we reach here, the player's move has not previously been explored
        var gameStateAfterPlayerMove = RootNode.GameState.ApplyMove(playerMove);
        var newNode = new Connect4Node(gameStateAfterPlayerMove);
        // If the game is over after the player's move, update the root and return
        if (gameStateAfterPlayerMove.GameOver)
        {
            RootNode = newNode;
            EmitSignal(nameof(MoveCalculatedEventHandler), -1);
        }

        // Calculate the best response from this new node
        GetBestMoveAsync(newNode);
    }
}
