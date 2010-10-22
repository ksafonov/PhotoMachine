/****************************************************************************\
 *
 *  (C) 2010 by Imagination Computer Services GesmbH. All rights reserved.
 *
 *  Project: flare
 *
 *  @author Stefan Hynst
 *
\****************************************************************************/

// derived from mr.doob's Hi-ReS! Stats class
// 
// released under MIT license: http://www.opensource.org/licenses/mit-license.php
//

package  at.imagination.flare
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;
import flash.system.System;
import flash.text.StyleSheet;
import flash.text.TextField;
import flash.utils.getTimer;	

// ----------------------------------------------------------------------------

public class Stats extends Sprite
{	
	private var m_xml:XML;
	private var m_graph:BitmapData;
	private var m_rectangle:Rectangle;
	private var m_text:TextField;
	
	private var m_fps:uint;
	private var m_ms:uint;
	private var m_msPrev:uint;
	
	private var m_profiler:Profiler;

    private var m_unit:uint; // ms

	// ------------------------------------------------------------------------

	public function Stats(unit:uint, prof:Profiler = null):void
	{
        this.m_unit = unit;

        m_profiler = prof;
		addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
	}

	// ------------------------------------------------------------------------

	private function init(e:Event):void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);

		graphics.beginFill(0x33);
		graphics.drawRect(0, 0, 70, 50);
		graphics.endFill();

		if (m_profiler) m_xml = <xml><mem>MEM:</mem><fps>FPS:</fps><ms>MS:</ms><upd>UPD:</upd></xml>;
		else            m_xml = <xml><mem>MEM:</mem><fps>FPS:</fps><ms>MS:</ms></xml>;
	
		var style:StyleSheet = new StyleSheet();
		style.setStyle("xml", {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
		style.setStyle("mem", {color: '#00FFFF'});
		style.setStyle("fps", {color: '#FFFF00'});
		style.setStyle("ms",  {color: '#00FF00'});
		if (m_profiler) style.setStyle("upd", {color: '#FF0000'});

		m_text = new TextField();
		m_text.width = 70;
		m_text.height = 50;
		m_text.styleSheet = style;
		m_text.condenseWhite = true;
		m_text.selectable = false;
		m_text.mouseEnabled = false;
		addChild(m_text);

		var bitmap:Bitmap = new Bitmap(m_graph = new BitmapData(70, 50, false, 0x33));
		bitmap.y = 50;
		addChild(bitmap);

		m_rectangle = new Rectangle(0, 0, 1, m_graph.height);			

		addEventListener(Event.ENTER_FRAME, update);
	}

	// ------------------------------------------------------------------------

	private function update(e:Event):void
	{
		var timer:uint;
		var mem:Number;
		var fps_graph:uint;
		var ms_graph:uint;
		var mem_graph:uint;
		var upd_graph:uint;
	
		timer = getTimer();
	
		if (timer - m_unit > m_msPrev)
		{
			m_msPrev = timer;
			mem = Number((System.totalMemory * 0.000000954).toFixed(3));

			fps_graph = Math.min(50, (m_fps / stage.frameRate) * 50);
			ms_graph  = Math.min(50, ((timer - m_ms) >> 1));
			mem_graph = Math.min(50, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
			if (m_profiler) upd_graph = Math.min(50, m_profiler.elapsed);

			m_graph.scroll(1, 0);

			m_graph.fillRect(m_rectangle , 0x33);
			m_graph.setPixel(0, m_graph.height - fps_graph, 0xFFFF00);
			m_graph.setPixel(0, m_graph.height - ms_graph , 0x00FF00);
			m_graph.setPixel(0, m_graph.height - mem_graph, 0x00FFFF);
			if (m_profiler) m_graph.setPixel(0, m_graph.height - upd_graph, 0xFF0000);

			m_xml.fps = "FPS: " + m_fps * 1000.0 / m_unit + " / " + stage.frameRate;
			m_xml.mem = "MEM: " + mem;
			if (m_profiler) m_xml.upd = "UPD: " + m_profiler.elapsed;

			m_fps = 0;
		}
		m_fps++;
	
		m_xml.ms = "MS: " + (timer - m_ms);
		m_ms = timer;

		m_text.htmlText = m_xml;
	}

	// ------------------------------------------------------------------------

}

// ----------------------------------------------------------------------------

}
