////////////////////////////////////////////////////////////////////////////////
///
///	Live Coding file made on 2024/04/19 from Tobias Koelker 
///
////////////////////////////////////////////////////////////////////////////////


s.quit;
s.record;
(
s.waitForBoot({

	SynthDef(\kick, {
		var sig, freqSweep, env;
		freqSweep = Env([\freq.ir(2000), 50, 20], [0.025, 1], [-8, -4]).ar;
		env = Env([0, 1, 0], [\atk.ir(0.005), \rel.ir(0.5)], [1, -12]).ar(2);
		sig = SinOsc.ar(freqSweep);
		sig = (sig * 1.1).clip(-1, 1);
		sig = Pan2.ar(sig.distort * 2, 0, \amp.ir(0.2));
		sig = LPF.ar(sig, \lpf.ir(20000).clip(20, 20000)) * env;
		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\hh, {

	}).add;

	SynthDef(\snarig, {
		var sig;
		sig = WhiteNoise.ar(Decay2.ar(PulseDivider.ar(0, 4, 2), 0.005, 0.5));
		sig = sig * 0.04;
		sig = sig * EnvGen.kr(Env.perc, doneAction: 0);
		sig = Pan2.ar(sig, SinOsc.ar(0.8));
		Out.ar(0, sig * \amp.ir);
	}).add;

	SynthDef(\saw, {
		var sig, env;
		env = Env.linen(
			\atk.ir(0.001), \sus.ir(0), \rel.ir(0.5),
			curve: [\ca.ir(-1), 0, \cr.ir(-4)]
		).ar(2);
		sig = Saw.ar(\freq.ir(1000) * 2.pow({ (\dtn.ir(0.05)/12).sum3rand } ! 8));
		sig = Splay.ar(sig);
		sig = LPF.ar(sig, \lpf.ir(20000).clip(20, 20000));
		sig = Balance2.ar(sig[0], sig[1], \pan.ir(0), \amp.ir(0.1)) * env;
		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\plucked1, {
		|freq = 440, amp = 0.5, mix = 0.1, coef = 0.8|
		var sig;
		var env = Env([0, 1, 0.5, 0], [0.01, 0.5, 0.5]);

		sig = Pluck.ar(WhiteNoise.ar(0.1), 1, freq.reciprocal, freq.reciprocal, 10, coef, 1, 0);
		//sig = Pluck.ar(WhiteNoise.ar(0.1), 1, 0.6, 0.1, 1, coef, 1, 0);
		sig = FreeVerb.ar(sig, mix);   //(sig, mix);
		sig = sig * EnvGen.kr(env, doneAction: Done.freeSelf) ! 2;
		sig = Balance2.ar(sig[0], sig[1], \pan.ir(0), amp);
		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\ambient, {
		|freq = 440, amp = 0.5, coef1 = 1, coef2 = 1, coef3 = 1|
		var sig;
		var ratios = [1, coef1, 1, 1, coef1, 1, 1, coef3];

		sig = Saw.ar(freq * ({ LFNoise2.kr(0.2) } ! 16 * Line.kr(0, 0.5, 3)).midiratio * ratios);
		//sig = DelayC.ar(sig, 0.5, 0.03);
		sig = Delay1.ar(sig);
		sig = Splay.ar(sig);
		sig = LPF.ar(sig, freq * 4);
		sig = BPeakEQ.ar(sig, freq * 8, 0.1, 8);
		sig = FreeVerb.ar(sig, 0.1, 0.9, 0.7);

		sig = sig * EnvGen.ar(
			Env(
				levels: [0, 0.4, 1, 0.7, 0],
				times: [1.8, 2.4, 3.9, 8.8]),
				doneAction: 1);
		sig = sig ! 2;

		Out.ar(\out.ir(0), sig * amp);
	}).add;
})
)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

(
p = ProxySpace.new.push;
t = TempoClock.new;
t.tempo_(120/60);
t.tempo.postln;
p = ProxySpace(clock: t.permanent_(true)).push;
n = 55; // base note
a = Scale.minor;
)


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

s.record;

(
~base = Pbind(
	\instrument, \saw,
	\dur, t.tempo / 8,
	\freq, Pseq([n] * 1, inf) * Prand([a.ratios[0], a.ratios[0], a.ratios[0], a.ratios[2], a.ratios[4]], inf),
	\db, Pseq([-1, -1, 0, -1, -0.6, -0.2, -1, 0], inf) * 24 - 30,
	\slev, 1,
	\rel, 0.2,
	\cr, -3,
	\atk, 0,
	\lpf, 400,
	\lrq, 0.5,
	\pan, Prand([0.6, 0.2, - 0.7, -0.5] * 0.2, inf),
)
)
~base.play;
~base.quant(1);
~base.stop;
~base.fadeTime = 1;



(
~drum = Pbind(
	\instrument, \kick,
	\dur, t.tempo / 1,
	\amp, 0.4,
)
)
~drum.play;
~drum.stop;
~drum.quant(1);


(
~ambient1 = Pbind(
	\instrument, \ambient,
	\dur, t.tempo * 12,
	\amp, 0.03,
	\freq, Pseq([4, 4, 5, 3] * n - 0, inf),
	\coef1, 1,
	\coef2, 1.2,
	\coef3, 1,
)
)

~ambient1.play;
~ambient1.quant(1);
~ambient1.stop;
~ambient1.fadeTime = 5;
~ambient1 = PfadeOut.new(~ambient1, 10);

(
~pluckMelody = Pbind(
	\instrument, \plucked1,
	//\dur, 0.4,
	\dur, Pseq([0.5, 0.75, 0.25, 0.25, 0.25,
				0.75, 0.25, 0.25, 0.25, 0.25, 0.25,
				0.5, 0.5, 0.5, 0.5,
				0.125, 0.125, 0.5, 0.25, 0.25, 0.25, 0.5,
				0.25, 0.5, 0.25, 1,
				1, 1, 1, 1, 1, 1, 1, 1,
			] * t.tempo / 2, inf),
	//\dur, Prand([0.125, 0.25, 0.25, 0.25, 0.25, 0.5, 0.5, 0.725, 1] * 1.2, inf),
	\amp, Prand([0.2, 0.4, 0.9, 0.8, 0.3] * 0.1, inf),
	//\amp, Pseq([1, 1, 0.1, 0, 1, 0.6, 0.2, 1, 0, 0.6, 0.7, 0, 0, 1, 0, 0, 0], inf),
	//\delta , Pseq([1,0.5,0,0.5,0.5,0.5,0.5,1,0.5,0.5,1,1],inf),
	//\freq, Pseq([100], inf) + Prand([20, 50, 100], inf),
	\freq, n * 4 * Prand(a.ratios, inf),
	\pan, 0.4,
	\mix, 0.1,
)
)
~pluckMelody.play;
~pluckMelody.quant = 1;
~pluckMelody.stop;
~pluckMelody.fadeTime = 8;


(
~snare1 = Pbind(
	\instrument, \snarig,
	\dur, Prand([1, 2, 3], 4),//Pseq([1, 1, 3, 1], 1),
	\amp, 0.002,
)
)
~snare1.play;
~snare1.quant = 1;
