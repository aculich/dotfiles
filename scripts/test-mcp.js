#!/usr/bin/env node

const { spawn } = require('child_process');
const readline = require('readline');

// Function to send a message to the MCP server and get the response
function sendToMCP(message) {
  return new Promise((resolve, reject) => {
    // Spawn the MCP server process
    const mcp = spawn('npx', ['-y', '@modelcontextprotocol/server-github']);
    let output = '';
    
    mcp.stdout.on('data', (data) => {
      output += data.toString();
      
      // Check if we have a complete response
      if (output.includes('"status":"success"') || output.includes('"status":"error"')) {
        try {
          const responseObj = JSON.parse(output);
          resolve(responseObj);
        } catch (e) {
          resolve(output);
        }
        
        // Clean up the process
        mcp.kill();
      }
    });
    
    mcp.stderr.on('data', (data) => {
      console.error(`MCP Error: ${data}`);
    });
    
    mcp.on('error', (error) => {
      reject(`MCP Process Error: ${error.message}`);
    });
    
    mcp.on('close', (code) => {
      if (code !== 0 && !output) {
        reject(`MCP Process exited with code ${code}`);
      }
    });
    
    // Send the message to the MCP server
    mcp.stdin.write(JSON.stringify(message) + '\n');
  });
}

// Main function to test the MCP
async function testMCP() {
  console.log('Testing GitHub MCP server...');
  
  try {
    // Test request - get current user info
    const testMessage = {
      "jsonrpc": "2.0",
      "id": "test-1",
      "method": "tools.call",
      "params": {
        "name": "get_authenticated_user",
        "arguments": {}
      }
    };
    
    console.log('Sending request to MCP server...');
    const response = await sendToMCP(testMessage);
    
    console.log('\nResponse from MCP server:');
    console.log(JSON.stringify(response, null, 2));
    
    if (response.result) {
      console.log('\n✅ MCP test successful! GitHub MCP server is working correctly.');
      console.log(`Authenticated as GitHub user: ${response.result.login}`);
    } else {
      console.log('\n❌ MCP test failed. Check the response for errors.');
    }
  } catch (error) {
    console.error('\n❌ MCP test failed with error:', error);
  }
}

// Run the test
testMCP(); 