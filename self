import asyncio
import websockets
import discord

connected_clients = set()

async def echo(websocket):
    try:
        connected_clients.add(websocket)
        print(f"New client connected. Total clients: {len(connected_clients)}")
        
        async for message in websocket:
            print(f"Server received: {message}")
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")
    finally:
        connected_clients.remove(websocket)
        print(f"Client disconnected. Total clients: {len(connected_clients)}")

async def send_websocket_message(data):
    if not connected_clients:
        print("No clients connected to send message")
        return
    
    print(f"Sending to {len(connected_clients)} clients: {data}")
    for client in connected_clients.copy():
        try:
            await client.send(data)
        except Exception as e:
            print(f"Error sending to client: {e}")
            connected_clients.remove(client)
            print(f"Removed disconnected client. Total clients: {len(connected_clients)}")

class MyClient(discord.Client):
    async def on_ready(self):
        print('Logged on as', self.user)

    async def on_message(self, message):
        if (isinstance(message.channel, discord.TextChannel) 
            and message.channel.name == '10m-plus-brainrot-notify'):
            
            name, jobid = None, None
            for field in message.embeds[0].fields:
                if field.name == '🏷️ Name':
                    name = field.value[2:-2]
                if field.name == 'Job ID (Mobile)':
                    jobid = field.value
            
            if name == "Unknown" or not jobid:
                return
            asyncio.create_task(send_websocket_message(jobid))

async def run_bot(token):
    client = MyClient()
    await client.start(token)

async def main():
    discord_token = input("Enter Discord token: ")
    
    async with websockets.serve(echo, "0.0.0.0", 1488):
        print("WebSocket server started on ws://127.0.0.1:1488")
        await run_bot(discord_token)

if __name__ == "__main__":
    asyncio.run(main())
