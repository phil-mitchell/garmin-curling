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

class EstimateSelectorMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _view as CurlingView;

    // Constructor
    function initialize(view as CurlingView) {
        MenuInputDelegate.initialize();
        _view = view;
    }

    // Handle the menu input
    function onMenuItem(item) as Void {
        if (item == :item0) {
            _view.addSplit(0);
        } else if (item == :item1) {
            _view.addSplit(1);
        } else if (item == :item2) {
            _view.addSplit(2);
        } else if (item == :item3) {
            _view.addSplit(3);
        } else if (item == :item4) {
            _view.addSplit(4);
        } else if (item == :item5) {
            _view.addSplit(5);
        } else if (item == :item6) {
            _view.addSplit(6);
        } else if (item == :item7) {
            _view.addSplit(7);
        } else if (item == :item8) {
            _view.addSplit(8);
        } else if (item == :item9) {
            _view.addSplit(9);
        } else if (item == :item10) {
            _view.addSplit(10);
        } else if (item == :item11) {
            _view.addSplit(11);
        } else if (item == :item12) {
            _view.addSplit(12);
        } else if (item == :item13) {
            _view.addSplit(13);
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
            if (Toybox has :ActivityRecording) {
                if(_view.isSessionRecording()) {
                    _view.onLap();
                    return true;
                }
                return _view.isSessionActive();
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

    function onHold(clickEvent as WatchUi.ClickEvent) as Lang.Boolean {
        if (_view.isSessionRecording()) {
            WatchUi.pushView(new Rez.Menus.EstimateSelectorMenu(), new EstimateSelectorMenuDelegate(_view), WatchUi.SLIDE_UP);
            return true;
        }
        return false;
    }
}

class CurlingView extends WatchUi.View {
    private var _labelStart as Text?;
    private var _labelResume as Text?;
    private var _labelStopwatch as Text?;
    private var _labelDrawCount as Text?;
    private var _labelHitCount as Text?;
    private var _labelBrushStrokeCount as Text?;
    private var _labelEndCount as Text?;
    private var _labelTime as Text?;
    private var _labelPulse as Text?;
    private var _labelEstimates as Array<Text?> = [] as Array<Text?>;
    private var _curling as CurlingProcess;
    private var _selectedEstimate as Number = -1;

    private var _clockTimer;

    private var NUM_ESTIMATES as Number = 14;

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
        _labelDrawCount = View.findDrawableById("id_draw_count") as Text;
        _labelHitCount = View.findDrawableById("id_hit_count") as Text;
        _labelBrushStrokeCount = View.findDrawableById("id_brush_stroke_count") as Text;
        _labelEndCount = View.findDrawableById("id_end_count") as Text;
        _labelTime = View.findDrawableById("id_time") as Text;
        _labelPulse = View.findDrawableById("id_pulse") as Text;

        for( var i = 0; i < NUM_ESTIMATES; ++i) {
            _labelEstimates.add(View.findDrawableById("id_estimate_" + i) as Text);
        }

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
        _labelStart.setVisible(!recording && !active);
        _labelResume.setVisible(!recording && active);
        for( var i = 0; i < _labelEstimates.size(); ++i) {
            _labelEstimates[i].setVisible(recording);
            _labelEstimates[i].setColor(0x214C0C);
        }   

        _labelDrawCount.setText("" + _curling.getDrawCount());
        _labelHitCount.setText("" + _curling.getDrawCount());
        _labelBrushStrokeCount.setText("" + _curling.getBrushStrokeCount());
        _labelEndCount.setText("" + _curling.getCurrentEnd());

        if(recording) {
            var stopwatch = _curling.getStopwatchValue();
            var stopwatchStr = (stopwatch/1000).format("%02d") + "." + (stopwatch%1000).format("%03d");
            _labelStopwatch.setText(stopwatchStr);

            var stopwatchEstimate = _curling.getStopwatchEstimate();
            if (stopwatchEstimate > -1) {
                _labelEstimates[stopwatchEstimate].setColor(0x6CED2D);
            }
        }

        var clockTime = System.getClockTime();
        var timeStr = clockTime.hour.format("%02d") + ":" + clockTime.min.format("%02d") + ":" + clockTime.sec.format("%02d");
        _labelTime.setText(timeStr);

        var pulse = _curling.getPulse();
        if( pulse > 0 ) {
            _labelPulse.setText("" + pulse);
        } else {
            _labelPulse.setText("--");
        }

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

    public function addSplit(result as Number) as Void {
        _curling.addSplit(result);
    }
}
