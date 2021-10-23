# Cloud Backup Client

A DrRacket plugin to automatically send code to the cloud.

## Check it out!

Clone this repo and run `raco pkg install` to install the plugin. Then open up and run `test-server.rkt` using DrRacket. Hit cmd/ctrl + S and you'll see that the client has sent a request to the webserver containing the contents of the definitions window.

#### Example:
![image](https://user-images.githubusercontent.com/23691775/138539183-fce35bcb-71c7-4a7a-a77f-d67daeb0abae.png)

## Project structure

### `tool.rkt`

Contains the logic of the client side plugin. Simply extends the definitions window to invoke a HTTP POST request every so often. Read the code for more details.

The request body follows this schema:

```json
{
  "content": "Some string containing the text in the definitions window",
  "metadata": {
    ...
  }
}
```

### `test.server.rkt`

Runs a simple Racket webserver that runs on port 5000 and prints all incoming POST requests. Used to test if this thing works at all.

### The rest
Mostly boilerplate for DrRacket plugins, don't bother looking at them.
