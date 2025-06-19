// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ToDoList DApp
 * @dev A decentralized ToDo list application on the blockchain
 * @author Your Name
 */
contract Project {
    
    // Structure to represent a ToDo item
    struct Todo {
        uint256 id;
        string content;
        bool completed;
        uint256 createdAt;
        address owner;
    }
    
    // State variables
    mapping(address => Todo[]) private userTodos;
    mapping(address => uint256) private todoCount;
    
    // Events
    event TodoAdded(address indexed user, uint256 indexed todoId, string content);
    event TodoCompleted(address indexed user, uint256 indexed todoId);
    event TodoDeleted(address indexed user, uint256 indexed todoId);
    
    // Modifiers
    modifier validTodoId(uint256 _todoId) {
        require(_todoId < userTodos[msg.sender].length, "Invalid todo ID");
        require(userTodos[msg.sender][_todoId].owner != address(0), "Todo does not exist");
        _;
    }
    
    /**
     * @dev Add a new todo item
     * @param _content The content/description of the todo item
     */
    function addTodo(string memory _content) public {
        require(bytes(_content).length > 0, "Todo content cannot be empty");
        require(bytes(_content).length <= 200, "Todo content too long");
        
        uint256 todoId = todoCount[msg.sender];
        
        Todo memory newTodo = Todo({
            id: todoId,
            content: _content,
            completed: false,
            createdAt: block.timestamp,
            owner: msg.sender
        });
        
        userTodos[msg.sender].push(newTodo);
        todoCount[msg.sender]++;
        
        emit TodoAdded(msg.sender, todoId, _content);
    }
    
    /**
     * @dev Mark a todo item as completed
     * @param _todoId The ID of the todo item to complete
     */
    function completeTodo(uint256 _todoId) public validTodoId(_todoId) {
        require(!userTodos[msg.sender][_todoId].completed, "Todo already completed");
        
        userTodos[msg.sender][_todoId].completed = true;
        
        emit TodoCompleted(msg.sender, _todoId);
    }
    
    /**
     * @dev Delete a todo item
     * @param _todoId The ID of the todo item to delete
     */
    function deleteTodo(uint256 _todoId) public validTodoId(_todoId) {
        // Move the last element to the deleted position and pop
        uint256 lastIndex = userTodos[msg.sender].length - 1;
        
        if (_todoId != lastIndex) {
            userTodos[msg.sender][_todoId] = userTodos[msg.sender][lastIndex];
            // Update the ID of the moved todo
            userTodos[msg.sender][_todoId].id = _todoId;
        }
        
        userTodos[msg.sender].pop();
        
        emit TodoDeleted(msg.sender, _todoId);
    }
    
    /**
     * @dev Get all todos for the calling user
     * @return Array of all user's todos
     */
    function getTodos() public view returns (Todo[] memory) {
        return userTodos[msg.sender];
    }
    
    /**
     * @dev Get a specific todo by ID
     * @param _todoId The ID of the todo item
     * @return The todo item
     */
    function getTodo(uint256 _todoId) public view validTodoId(_todoId) returns (Todo memory) {
        return userTodos[msg.sender][_todoId];
    }
    
    /**
     * @dev Get the total number of todos for the calling user
     * @return The total number of todos
     */
    function getTodoCount() public view returns (uint256) {
        return userTodos[msg.sender].length;
    }
    
    /**
     * @dev Get the number of completed todos for the calling user
     * @return The number of completed todos
     */
    function getCompletedCount() public view returns (uint256) {
        uint256 completedCount = 0;
        Todo[] memory todos = userTodos[msg.sender];
        
        for (uint256 i = 0; i < todos.length; i++) {
            if (todos[i].completed) {
                completedCount++;
            }
        }
        
        return completedCount;
    }
    
    /**
     * @dev Get the number of pending (incomplete) todos for the calling user
     * @return The number of pending todos
     */
    function getPendingCount() public view returns (uint256) {
        return getTodoCount() - getCompletedCount();
    }
}
