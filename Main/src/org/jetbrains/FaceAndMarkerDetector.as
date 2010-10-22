/**
 * Created by IntelliJ IDEA.
 * User: ksafonov
 * Date: 19.10.10
 * Time: 23:29
 * To change this template use File | Settings | File Templates.
 */
package org.jetbrains {
import com.transmote.flar.marker.FLARMarker;
import com.transmote.flar.source.IFLARSource;
import com.transmote.flar.tracker.FLARToolkitManager;
import com.transmote.flar.tracker.IFLARTrackerManager;
import com.transmote.flar.utils.FLARManagerConfigLoader;
import com.transmote.flar.utils.threshold.IThresholdAdapter;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Stage;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

import jp.maaash.ObjectDetection.ObjectDetector;
import jp.maaash.ObjectDetection.ObjectDetectorOptions;

public class FaceAndMarkerDetector extends EventDispatcher implements IFLARTrackerManager {

    public static const FACE_MARKER_ID:int = 0xABCDEF;

    private static const FACE_DETECTION_SCALE:int = 2;

    private var _markerDetectionManager:FLARToolkitManager;
    private var _faceDetector:ObjectDetector;
    private var _detectionMap:BitmapData;
    private var _drawMatrix:Matrix;

    public function FaceAndMarkerDetector() {
        _markerDetectionManager = new FLARToolkitManager();

        _faceDetector = new ObjectDetector();
        var options:ObjectDetectorOptions = new ObjectDetectorOptions();
        options.min_size = 30;
        options.search_mode = ObjectDetectorOptions.SEARCH_MODE_NO_OVERLAP | ObjectDetectorOptions.SEARCH_MODE_SOLO;
        _faceDetector.options = options;
    }

    public function get id():String {
        return "FLARToolkitManager";
    }

    public function get trackerSource():IFLARSource {
        return _markerDetectionManager.trackerSource;
    }

    public function set trackerSource(flarSource:IFLARSource):void {
        _markerDetectionManager.trackerSource = flarSource;
    }

    public function get thresholdAdapter():IThresholdAdapter {
        return _markerDetectionManager.thresholdAdapter;
    }

    public function set thresholdAdapter(thresholdAdapter:IThresholdAdapter):void {
        _markerDetectionManager.thresholdAdapter = thresholdAdapter;
    }

    public function get threshold():Number {
        return _markerDetectionManager.threshold;
    }

    public function set threshold(threshold:Number):void {
        _markerDetectionManager.threshold = threshold;
    }

    public function get thresholdSourceDisplay():Boolean {
        return _markerDetectionManager.thresholdSourceDisplay;
    }

    public function set thresholdSourceDisplay(val:Boolean):void {
        _markerDetectionManager.thresholdSourceDisplay = val;
    }

    public function getProjectionMatrix(frameworkId:int, viewportSize:Rectangle):Matrix3D {
        return _markerDetectionManager.getProjectionMatrix(frameworkId, viewportSize);
    }

    public function get thresholdSourceBitmap():Bitmap {

        return _markerDetectionManager.thresholdSourceBitmap;
    }

    public function loadTrackerConfig(configLoader:FLARManagerConfigLoader):void {
        _markerDetectionManager.loadTrackerConfig(configLoader);
    }

    public function initTracker(stage:Stage = null):void {
        _markerDetectionManager.initTracker(stage);
    }

    public function performSourceAdjustments():void {
        _markerDetectionManager.performSourceAdjustments();
    }

    public function detectMarkers():Vector.<FLARMarker> {
        var markers:Vector.<FLARMarker> = _markerDetectionManager.detectMarkers();

        if (_detectionMap == null) {
            _detectionMap = new BitmapData(trackerSource.sourceSize.width / FACE_DETECTION_SCALE, trackerSource.sourceSize.height / FACE_DETECTION_SCALE, false, 0);
            _drawMatrix = new Matrix(1 / FACE_DETECTION_SCALE, 0, 0, 1 / FACE_DETECTION_SCALE);
        }

        _detectionMap.draw(trackerSource.source, _drawMatrix, null, "normal", null, true);
        _faceDetector.detect(_detectionMap);

        for each (var r:Rectangle in _faceDetector.detected) {
            var left:Number = (_detectionMap.width - r.right) * FACE_DETECTION_SCALE / trackerSource.trackerToDisplayRatio;
            var right:Number = (_detectionMap.width - r.left) * FACE_DETECTION_SCALE / trackerSource.trackerToDisplayRatio;
            var top:Number = r.top * FACE_DETECTION_SCALE / trackerSource.trackerToDisplayRatio;
            var bottom:Number = r.bottom * FACE_DETECTION_SCALE / trackerSource.trackerToDisplayRatio;


            var martix:Matrix3D = new Matrix3D();
            martix.position = new Vector3D(left, top);

            var corners:Vector.<Point> = new Vector.<Point>();
            corners.push(new Point(left, top));
            corners.push(new Point(left, bottom));
            corners.push(new Point(right, bottom));
            corners.push(new Point(right, top));
            var m:FaceMarker = new FaceMarker(martix, trackerSource, corners);

            if (markers == null) {
                markers = new Vector.<FLARMarker>();
            }
            markers.push(m);
        }
        return markers;
    }

    public function dispose():void {
        _markerDetectionManager.dispose();
    }

    override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
        if (type == Event.COMPLETE || type == Event.INIT || ErrorEvent.ERROR) {
            _markerDetectionManager.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }

    override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
        if (type == Event.COMPLETE || type == Event.INIT || ErrorEvent.ERROR) {
            _markerDetectionManager.removeEventListener(type, listener, useCapture);
        }
        super.removeEventListener(type, listener, useCapture);
    }

}
}

import com.transmote.flar.marker.FLARMarker;
import com.transmote.flar.source.IFLARSource;

import flash.geom.Matrix3D;
import flash.geom.Point;

import org.jetbrains.FaceAndMarkerDetector;

class FaceMarker extends FLARMarker {

    function FaceMarker(transformMatrix:Matrix3D, flarSource:IFLARSource, c:Vector.<Point>) {
        super(FaceAndMarkerDetector.FACE_MARKER_ID, transformMatrix, flarSource);
        _corners = c;
    }
}