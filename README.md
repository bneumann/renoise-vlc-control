# Renoise VLC video control
Remote control VLC from inside Renoise. This tool allows you to start and stop a video at the (almost) correct time of the Renoise track. If you are doing soundtracks this might be interesting for you!

## Installation
You need VLC installed to use this tool. Which might sound obvious but you never know. It worked right away for me, so VLC seemed to have installed itself to the ```PATH``` variable in Windows (For not-nerd: If a program is listed there, you can called it from anywhere in the windows system). If you experience problems let me know.

To install VLC follow the instructions here: http://www.videolan.org/vlc/

### Manually
Copy the de.newbucket.VlcCOntrol.xrnx to your ```%APPDATA%\Renoise\V3.1.0\Scripts\Tools directory```. For Windows 7 this would be ```C:\Users\benni\AppData\Roaming\Renoise\V3.1.0\Scripts\Tools```. Only if you happen to be benni of course, otherwise it's your name, duh!
### Automaticaly
If Renoise accepts my commit I will post an automatic way here. So long please look for the manual way or take the latest version from the ```release``` folder and drag-n-drop it over Renoise.

## Usage
This is pretty easy. Once installed you will have an entry ```~Start VLC with remote interface``` under the ```Tools``` menu. If you click it VLC will start in foreground mode but you can minify it.

If you load a video VLC starts this video. Unless your song is already playing you should __stop__ it and leave the control to Renoise. I haven't spend the effort yet to sync VLC backwards meaning Renoise can start the video, but VLC can't start the songs. This would be possible but I wanted to write music not code so I was a bit lazy. Feel free to help :)

That's it! Once the video is loaded you can play along with Renoise. Awesome!
