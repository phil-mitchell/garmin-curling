import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

// This delegate handles input for the Menu pushed when the user
// hits the stop button
class MainMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _view as CurlingView;

    // Constructor
    function initialize(view as CurlingView) {
        MenuInputDelegate.initialize();
        _view = view;
    }

    // Handle the menu input
    function onMenuItem(item) as Void {
        if (item == :resume) {
            _view.onStart();
        } else if (item == :save) {
            _view.onSave();
        } else if (item == :discard) {
            _view.onDiscard();
        }
    }
}

class BaseInputDelegate extends WatchUi.BehaviorDelegate {

    private var _view as CurlingView;

    //! Constructor
    //! @param view The app view
    public function initialize(view as CurlingView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    //! On menu event, start/stop recording
    //! @return true if handled, false otherwise
    public function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();
        System.println(key as Number);
        if (key == WatchUi.KEY_START || key == WatchUi.KEY_ENTER) {
            if (Toybox has :ActivityRecording) {
                if (!_view.isSessionRecording()) {
                    _view.onStart();
                } else {
                    _view.onStop();
                    WatchUi.pushView(new Rez.Menus.MainMenu(), new MainMenuDelegate(_view), WatchUi.SLIDE_UP);
                }
                return true;
            }
        } else if(key == WatchUi.KEY_LAP || key == WatchUi.KEY_ESC) {
            if (Toybox has :ActivityRecording && _view.isSessionRecording()) {
                _view.onLap();
                return true;
            }
        }
        return false;
    }

    // Block access to the menu button
    function onMenu() as Lang.Boolean {
        return _view.isSessionActive();
    }

    function onSwipe(swipeEvent as WatchUi.SwipeEvent) as Lang.Boolean {
         return _view.isSessionActive();
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
        if (_view.isSessionRecording()) {
            _view.onStopwatchToggle();
            return true;
        }
        return false;
    }
}

class CurlingView extends WatchUi.View {
    private var _labelStart as Text?;
    private var _labelResume as Text?;
    private var _labelStopwatch as Text?;
    private var _labelThrowCount as Text?;
    private var _labelBrushStrokeCount as Text?;
    private var _labelThrowIcon as Text?;
    private var _labelBrushStrokeIcon as Text?;
    private var _labelTime as Text?;
    private var _curling as CurlingProcess;

    private var _clockTimer;

    //! Constructor
    public function initialize() {
        View.initialize();
        _curling = new $.CurlingProcess();
        _clockTimer =  new Timer.Timer();
    }

    //! Set the layout
    //! @param dc Device context
    public function onLayout(dc) as Void {
        setLayout($.Rez.Layouts.MainLayout(dc));
        _labelStart = View.findDrawableById("id_start") as Text;
        _labelResume = View.findDrawableById("id_resume") as Text;
        _labelStopwatch = View.findDrawableById("id_stopwatch") as Text;
        _labelThrowCount = View.findDrawableById("id_throw_count") as Text;
        _labelBrushStrokeCount = View.findDrawableById("id_brush_stroke_count") as Text;
        _labelThrowIcon = View.findDrawableById("id_throw_icon") as Text;
        _labelBrushStrokeIcon = View.findDrawableById("id_brush_stroke_icon") as Text;
        _labelTime = View.findDrawableById("id_time") as Text;

        _clockTimer.start(method(:onClockUpdate), 100, true);
    }

    public function isSessionRecording() as Boolean {
        return _curling.isSessionRecording();
    }

    public function isSessionActive() as Boolean {
        return _curling.isSessionActive();
    }

    public function onStart() as Void {
        _curling.onStart();
        WatchUi.requestUpdate();
    }

    //! Update the view
    //! @param dc Device Context
    public function onUpdate(dc as Dc) as Void {
        var recording = isSessionRecording();
        var active = isSessionActive();

        _labelStopwatch.setVisible(recording);
        _labelThrowCount.setVisible(recording);
        _labelBrushStrokeCount.setVisible(recording);
        _labelThrowIcon.setVisible(recording);
        _labelBrushStrokeIcon.setVisible(recording);
        _labelStart.setVisible(!recording && !active);
        _labelResume.setVisible(!recording && active);

        if(recording) {
            _labelThrowCount.setText("" + _curling.getDrawCount() + " D\n" + _curling.getHitCount() + " H");
            _labelBrushStrokeCount.setText("" + _curling.getBrushStrokeCount());

            var stopwatch = _curling.getStopwatchValue();
            var stopwatchStr = (stopwatch/1000).format("%02d") + "." + (stopwatch%1000).format("%03d");
            _labelStopwatch.setText(stopwatchStr);
        }

        var clockTime = System.getClockTime();
        var timeStr = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d") + ":" + clockTime.sec.format("%02d");
        _labelTime.setText(timeStr);

        View.onUpdate(dc);
    }

    public function onClockUpdate() as Void {
        WatchUi.requestUpdate();
    }

    public function onStop() as Void {
        _curling.onStop();
        WatchUi.requestUpdate();
    }

    public function onSave() as Void {
        _curling.resetSession(true);
    }

    public function onDiscard() as Void {
        _curling.resetSession(false);
    }

    public function onLap() as Void {
        _curling.onLap();
        WatchUi.requestUpdate();
    }

    public function onStopwatchToggle() as Void {
        _curling.toggleStopwatch();
    }
}
