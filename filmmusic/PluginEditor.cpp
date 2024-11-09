/*
  ==============================================================================

    This file contains the basic framework code for a JUCE plugin editor.

  ==============================================================================
*/

#include "PluginProcessor.h"
#include "PluginEditor.h"

//==============================================================================
TetrisAudioProcessorEditor::TetrisAudioProcessorEditor (TetrisAudioProcessor& p)
    : AudioProcessorEditor (&p), audioProcessor (p)
{
    /// MARK: Beim Erstellen dieses TetrisAudioProcessorEditors wurde uns eine Referenz mitgegeben zu unserem TetrisAudioProcessor. Eine Referenz ist durch das & Zeichen in "TetrisAudioProcessor& p" zu erkennen. Die Referenz zu wurde dann in der member variable audioProcessor gespeichert. Die können wir nun nutzen, um den gerade geöffneten PluginEditor der ListenerListe hinzuzufügen. "this" ist hierbei ein Pointer zu dem existierenden Objekt unseres Editors.
    audioProcessor.addMidiListener(this);
    
    // Make sure that before the constructor has finished, you've set the
    // editor's size to whatever you need it to be.
    setSize (400, 300);
}

TetrisAudioProcessorEditor::~TetrisAudioProcessorEditor()
{
    /// MARK: Genauso wie wir oben diese Instanz von TetrisAudioProcessorEditor hinzugefügt haben, müssen wir sie vor dem Löschen der Instanz wieder entfernen. Ansonsten würde weiterhin versucht werden, an diese Instanz Midi Nachrichten zu schicken, obwohl sie schon längst nicht mehr existiert.
    audioProcessor.removeMidiListener(this);
}

//==============================================================================
void TetrisAudioProcessorEditor::paint (juce::Graphics& g)
{
    // (Our component is opaque, so we must completely fill the background with a solid colour)
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));

    g.setColour (juce::Colours::white);
    g.setFont (15.0f);
    g.drawFittedText ("Hello World!", getLocalBounds(), juce::Justification::centred, 1);
}

void TetrisAudioProcessorEditor::resized()
{
    // This is generally where you'll want to lay out the positions of any
    // subcomponents in your editor..
}

/// MARK: Hier kommen nun die MidiMessages an.
void TetrisAudioProcessorEditor::midiMessageReveived(const MidiMessage &msg)
{
    DBG (msg.getDescription());
}
