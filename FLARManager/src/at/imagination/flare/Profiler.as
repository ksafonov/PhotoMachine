/****************************************************************************\
 *
 *  (C) 2010 by Imagination Computer Services GesmbH. All rights reserved.
 *
 *  Project: flare
 *
 *  @author Stefan Hynst
 *
\****************************************************************************/

package at.imagination.flare
{

import flash.utils.getTimer;
	
// ----------------------------------------------------------------------------

public class Profiler
{
	private var m_profileCnt:uint;
	private var m_numSamples:uint;
	private var m_valueAccu:Number;
	private var m_elapsed:uint;

	private var m_t:uint;

	private static var _profilerCB:Function = null;

	// ------------------------------------------------------------------------

	public static function setProfileCallback(funcCB:Function):void
	{
		_profilerCB = funcCB;
	}

	// ------------------------------------------------------------------------

	public function Profiler(numSamples:uint)
	{
		m_numSamples = numSamples;
		m_profileCnt = 0;
		m_valueAccu  = 0;
		m_elapsed    = 0;
	}

	// ------------------------------------------------------------------------

	public function get elapsed():uint		{ return m_elapsed;  }
	
	// ------------------------------------------------------------------------

	public function measureStart():void
	{
		if (m_numSamples == 0) return;
		m_t = getTimer();
	}

	// ------------------------------------------------------------------------

	public function measureEnd():void
	{
		if (m_numSamples == 0) return;

		m_valueAccu += (getTimer() - m_t);

		if (++m_profileCnt == m_numSamples)
		{
			m_profileCnt = 0;
			m_elapsed    = m_valueAccu / m_numSamples;
			if (_profilerCB != null) _profilerCB(this);
			m_valueAccu = 0;
		}
	}

	// ------------------------------------------------------------------------
	
}

// ----------------------------------------------------------------------------

}
