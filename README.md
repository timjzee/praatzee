# PraatZee
A collection of useful Praat scripts

## Installation
Download the `plugin_PraatZee` folder and place it in your Praat preferences folder.
- macOS: `/Users/UserName/Library/Preferences/Praat Prefs/`
- Linux: `/UserName/.praat-dir/`
- Windows: `C:\Users\UserName\Praat\`

## Description of included scripts

### extractPeriodicity.praat
For whatever reason Praat does not allow you to extract parts of Pitch objects and other objects that are derived from a pitch analysis. However, in certain cases it is necessary to do the pitch analysis before extracting a part of the signal. This script implements such functionality for Pitch and Harmonicity objects. When selecting these type of objects an additional "Extract part..." button appears in Praat's dynamic menu. See my [blog post](http://www.timzee.nl/phonetics/praat/2019/04/14/extractperiodicity.html) for more info.

### insertSilence.praat
Inserts a pause into an audio fragment at a specified time.
