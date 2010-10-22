package
{
import at.imagination.flare.Stats;

import com.quasimondo.bitmapdata.CameraBitmap;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import jp.maaash.ObjectDetection.ObjectDetector;
	import jp.maaash.ObjectDetection.ObjectDetectorEvent;
	import jp.maaash.ObjectDetection.ObjectDetectorOptions;
	
	public class FaceDetector_Camera extends Sprite
	{
		
		private var detector    :ObjectDetector;
		private var options     :ObjectDetectorOptions;
		
		private var view :Sprite;
		private var faceRectContainer :Sprite;
		private var tf :TextField;
		
		private var camera:CameraBitmap;
		private var detectionMap:BitmapData;
		private var drawMatrix:Matrix;
		private var scaleFactor:int = 4;
		private var w:int = 640;
		private var h:int = 480;
		
		private var lastTimer:int = 0;
		

		public function FaceDetector_Camera() {
			initUI();
			initDetector();
			
		}

		private function initUI():void{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;

			view = new Sprite;
			addChild(view);

			camera = new CameraBitmap( w, h, 25 );
			camera.addEventListener( Event.RENDER, cameraReadyHandler );
			view.addChild( new Bitmap( camera.bitmapData ) );
			
			detectionMap = new BitmapData( w / scaleFactor, h / scaleFactor, false, 0 );
			drawMatrix = new Matrix( 1/ scaleFactor, 0, 0, 1 / scaleFactor );
			
			faceRectContainer = new Sprite;
			view.addChild( faceRectContainer );

            var s : Stats = new Stats(250, null);
            addChild(s);
		}

		private function cameraReadyHandler( event:Event ):void
		{
			detectionMap.draw(camera.bitmapData,drawMatrix,null,"normal",null,true);
			detector.detect( detectionMap );
		}

		private function initDetector():void
		{
			detector = new ObjectDetector();
			
			var options:ObjectDetectorOptions = new ObjectDetectorOptions();
			options.min_size  = 30;
            options.search_mode = ObjectDetectorOptions.SEARCH_MODE_SOLO | ObjectDetectorOptions.SEARCH_MODE_NO_OVERLAP;
			detector.options = options;
			detector.addEventListener(ObjectDetectorEvent.DETECTION_COMPLETE, detectionHandler );
		}
		
		
		
		private function detectionHandler( e :ObjectDetectorEvent ):void
		{
			var g :Graphics = faceRectContainer.graphics;
			g.clear();
			if( e.rects ){
				g.lineStyle( 2 );	// black 2pix
				e.rects.forEach( function( r :Rectangle, idx :int, arr :Array ) :void {
					g.drawRect( r.x * scaleFactor, r.y * scaleFactor, r.width * scaleFactor, r.height * scaleFactor );
				});
			}
			
		}

		

	
	}
}
