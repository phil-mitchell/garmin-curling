//
// Copyright 2016-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Sensor;
import Toybox.SensorLogging;
import Toybox.System;
import Toybox.WatchUi;

//! Processes accelerometer data and counts throws and brush strokes
class CurlingProcess {
    private const SWEEP_THR_Y = 1000;
    private const SWEEP_WAVELENGTH = 10;

    private var _x as Array<Float> = [0.0] as Array<Float>;
    private var _y as Array<Number> = [0] as Array<Number>;
    private var _yPrev as Array<Number> = [0] as Array<Number>;
    private var _z as Array<Number> = [0] as Array<Number>;
    private var _filter as FirFilter?;

    private var _drawCount as Number = 0;
    private var _hitCount as Number = 0;
    private var _brushStrokeCount as Number = 0;
    private var _lastBrushStrokeCounted as Number = 0;
    private var _lastIntervalBrushStrokeCountRecorded as Number = 0;
    private var _lastSessionBrushStrokeCountRecorded as Number = 0;

    private var _stopwatch as Number = 0;
    private var _stopwatchBase as Number = 0;

    private var _logger as SensorLogger?;
    private var _session as Session?;

    private var _intervalBrushStrokesField;
    private var _lapBrushStrokesField;
    private var _sessionBrushStrokesField;

    private var _intervalDrawsField;
    private var _lapDrawsField;
    private var _sessionDrawsField;

    private var _intervalHitsField;
    private var _lapHitsField;
    private var _sessionHitsField;

    //! Constructor
    public function initialize() {
        // initialize FIR filter
        var options = {:coefficients => [-0.0278f, 0.9444f, -0.0278f] as Array<Float>, :gain => 0.001f};
        try {
            _filter = new Math.FirFilter(options);
            _logger = new SensorLogging.SensorLogger({:accelerometer => {:enabled => true}});
        } catch (e) {
            System.println(e.getErrorMessage());
        }
    }

    //! Callback to receive accel data
    //! @param sensorData The Sensor Data object
    public function accelCallback(sensorData as SensorData) as Void {
        var accelData = sensorData.accelerometerData;
        if (accelData != null) {
            _yPrev = _y;
            _lastBrushStrokeCounted -= _yPrev.size();
            if (_filter != null) {
                _x = _filter.apply(accelData.x);
            }
            _y = accelData.y;
            _z = accelData.z;
            onAccelData();
        }
    }

    //! Start sweep/throw counter
    public function onStart() as Void {
        if (_session == null) {
            _session = ActivityRecording.createSession({:name=>"Curling", :sport=>ActivityRecording.SPORT_GENERIC, :sensorLogger =>_logger as SensorLogger});
            // Create the new FIT fields to record to.
            _intervalBrushStrokesField = _session.createField("Brush strokes", 0, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_RECORD});
            _lapBrushStrokesField = _session.createField("End brush strokes", 1, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_LAP});
            _sessionBrushStrokesField = _session.createField("Total brush strokes", 2, FitContributor.DATA_TYPE_UINT16, {:mesgType => FitContributor.MESG_TYPE_SESSION});

            _intervalDrawsField = _session.createField("Draws", 3, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_RECORD});
            _lapDrawsField = _session.createField("End draws", 4, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_LAP});
            _sessionDrawsField = _session.createField("Total draws", 5, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION});

            _intervalHitsField = _session.createField("Hits", 6, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_RECORD});
            _lapHitsField = _session.createField("End hits", 7, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_LAP});
            _sessionHitsField = _session.createField("Total hits", 8, FitContributor.DATA_TYPE_UINT8, {:mesgType => FitContributor.MESG_TYPE_SESSION});
        }

        // initialize accelerometer
        var options = {:period => 1, :accelerometer => {:enabled => true, :sampleRate => 25}};
        try {
            Sensor.registerSensorDataListener(method(:accelCallback), options);
            if (_session != null) {
                _session.start();
            }
        } catch(e) {
            System.println(e.getErrorMessage());
        }
    }

    //! Stop sweep/throw counter
    public function onStop() as Void {
        Sensor.unregisterSensorDataListener();
        if (_session != null) {
            _session.stop();
        }
    }

    private function resetData() as Void {
        _drawCount = 0;
        _hitCount = 0;
        _brushStrokeCount = 0;
        _lastBrushStrokeCounted = 0;
        _lastIntervalBrushStrokeCountRecorded = 0;
        _y = [0] as Array<Number>;
        _yPrev = [0] as Array<Number>;
        _stopwatch = 0;
        _stopwatchBase = 0;
    }

    public function resetSession(save as Boolean) as Void {
        var session = _session;
        _session = null;
        resetData();
        _lastSessionBrushStrokeCountRecorded = 0;

        if (session != null) {
            if (save) {
                session.save();
            } else {
                session.discard();
            }

        }
    }

    //! Stop sweep/throw counter
    public function onLap() as Void {
        if (_session != null) {
            _session.addLap();
            resetData();
        }
    }

    //! Return current throw count
    //! @return The number of draws counted
    public function getDrawCount() as Number {
        return _drawCount;
    }

    //! Return current throw count
    //! @return The number of hits counted
    public function getHitCount() as Number {
        return _hitCount;
    }

    //! Return current brush stroke count
    //! @return The number of brush strokes counted
    public function getBrushStrokeCount() as Number {
        return _brushStrokeCount;
    }

    //! Get the total number of seconds of logged data
    //! @return The number of seconds of logged data
    public function getPeriod() as Number? {
        if (_logger != null) {
            var stats = _logger.getStats();
            if (stats != null) {
                return stats.samplePeriod;
            }
        }
        return null;
    }

    //! Process new accel data
    private function onAccelData() as Void {
        var cur_acc_x = 0;
        var cur_acc_y = 0;
        var cur_acc_z = 0;
        var prev_acc_y = 0;
        var interval_brush_stroke_count = 0;

        for (var i = 0; i < _x.size(); ++i) {
            cur_acc_x = _x[i];
            cur_acc_y = _y[i];
            cur_acc_z = _z[i];

            if (cur_acc_y.abs() > SWEEP_THR_Y) {
                // sweeping?
                // we are either pushing or pulling
                // look back in time for when we were
                // doing the opposite with sufficient acceleration
                var direction_changed = false;
                for (var j = 1; j < SWEEP_WAVELENGTH && (i-j) >= _lastBrushStrokeCounted; ++j) {
                    prev_acc_y = 0;
                    if (j > i) {
                        if(_yPrev.size() > (j-i)) {
                            prev_acc_y = _yPrev[_yPrev.size()-(j-i)];
                        }
                    } else {
                        prev_acc_y = _y[i-j];
                    }

                    if (!direction_changed && prev_acc_y != 0 && (prev_acc_y < 0) != (cur_acc_y < 0) && prev_acc_y.abs() > SWEEP_THR_Y) {
                        direction_changed = true;
                    } else if (direction_changed && prev_acc_y != 0 && (prev_acc_y < 0) == (cur_acc_y < 0) && prev_acc_y.abs() > SWEEP_THR_Y) {
                        interval_brush_stroke_count ++;
                        _lastBrushStrokeCounted = i;
                        break;
                    }
                }
            }
        }

        if (interval_brush_stroke_count > 0) {
            _brushStrokeCount += interval_brush_stroke_count;
            _lastSessionBrushStrokeCountRecorded += interval_brush_stroke_count;
            _lastIntervalBrushStrokeCountRecorded = interval_brush_stroke_count;

            _lapBrushStrokesField.setData(_brushStrokeCount);
            _sessionBrushStrokesField.setData(_lastSessionBrushStrokeCountRecorded);
            _intervalBrushStrokesField.setData(interval_brush_stroke_count);
        } else if (_lastIntervalBrushStrokeCountRecorded != 0) {
            _lastIntervalBrushStrokeCountRecorded = 0;
            _intervalBrushStrokesField.setData(interval_brush_stroke_count);
        }
    }

    public function isSessionRecording() as Boolean {
        if (_session != null) {
            return _session.isRecording();
        }
        return false;
    }
    public function isSessionActive() as Boolean {
        return _session != null;
    }

    public function getStopwatchValue() as Number {
        if (_stopwatchBase != 0) {
            _stopwatch = System.getTimer() - _stopwatchBase;
        }
        return _stopwatch;
    }

    public function toggleStopwatch() {
        if (_stopwatchBase != 0) {
            getStopwatchValue();
            _stopwatchBase = 0;
        } else {
            _stopwatchBase = System.getTimer();
        }
    }
}
