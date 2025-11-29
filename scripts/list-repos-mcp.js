#!/usr/bin/env node

const { spawn } = require('child_process');

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

// Main function to list repositories
async function listRepositories() {
  console.log('Listing your GitHub repositories via MCP...');
  
  try {
    // Request to list user repositories
    const message = {
      "jsonrpc": "2.0",
      "id": "list-repos",
      "method": "tools.call",
      "params": {
        "name": "list_repositories",
        "arguments": {
          "visibility": "all",
          "sort": "updated"
        }
      }
    };
    
    const response = await sendToMCP(message);
    
    if (response.result) {
      console.log('\nYour GitHub Repositories:');
      response.result.forEach((repo, index) => {
        console.log(`${index + 1}. ${repo.name} - ${repo.html_url}`);
        console.log(`   Description: ${repo.description || 'No description'}`);
        console.log(`   Language: ${repo.language || 'Not specified'}`);
        console.log(`   Updated: ${new Date(repo.updated_at).toLocaleString()}`);
        console.log('');
      });
    } else {
      console.log('\nFailed to list repositories. Check the response for errors:');
      console.log(JSON.stringify(response, null, 2));
    }
  } catch (error) {
    console.error('\nError listing repositories:', error);
  }
}

// Run the function
listRepositories();