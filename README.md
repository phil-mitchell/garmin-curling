# Curling activity tracker for Garmin devices

This app for Garmin devices allows you to track your curling game as activities.
It counts brush strokes, draws, and hits for each end.

It also includes a stopwatch that sweepers can use to measure backline-to-hog split-time.
The stopwatch also includes an estimate for where the rock will stop.
By updating the actual stopping position for the given time, the estimates will be updated.
This can be used to roughly gauge how hard the rock was thrown.
However, since every path on the ice is different and changes throughout the game, I make no claims that it will be perfect.

If you find this app useful, please [buy me a coffee](https://ko-fi.com/philmitchell).

## Usage

Upon opening the app, you will see a prompt to start the activity.
Once you start it, you will now see and be able to use the stopwatch.

As you mark an end, the counters will reset.
The totals will appear on the final report.

When the game is over, you can stop the activity.
This will display a menu from which you can choose to continue (if this was an accident), save (upload a report of the activity), or discard (pretend this never happened).

While using the stopwatch, you can choose to mark the position of the rock that you timed.
You will be presented with a menu with "HOG", the nubmers 1-10 (correspoding to the standard [number weights](https://en.wikipedia.org/wiki/Glossary_of_curling)), and HACK, BOARD, and HIT.
Choose the entry that most closely corresponds to what the rock did.

**Warning**:
You cannot move back to the watch screen during the activity.
Garmin has a limitation for custom apps that immediately exit the app as soon as you return to the watch screen.
This abrupt exit causes the activity to be saved without the final summary and is generally pretty annoying.
To protect you from this behaviour, the app disables all methods of returning to the watch screen while an activity is being recorded.
If you want to return to the watch screen, you must first stop the activity and either save or discard it.

The exact controls depend on which device you're using.

### Touch-screen 5-button devices (e.g. fēnix® devices)

Top-right button will start/stop the activity.
Bottom-right button will mark a new end.
Tap the screen OR "up" button (middle left) to start/stop the stopwatch.
Hold the screen OR "menu" button (hold middle left) to update the actual stopping position of the rock.

### Touch-screen 2-button devices (e.g. vivoactive 4+)

Top-right button will start/stop the activity.
Bottom-right button will mark a new end.
Tap the screen to start/stop the stopwatch.
Hold the screen to update the actual stopping position of the rock.

### Touch-creen 1-button devices (e.g. vivoactive 3)

Button with start/stop the activity.
Swipe-right will mark a new end.
Tap the screen to start/stop the stopwatch.
Swipe-up to update the actual stopping position of the rock.

### 5-button devices (e.g. MARQ® devices)

Top-right button will start/stop the activity.
Bottom-right button will mark a new end.
Up button (middle left) to start/stop the stopwatch.
Menu button (hold middle left) to update the actual stopping position of the rock.