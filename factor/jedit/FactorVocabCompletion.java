/* :folding=explicit:collapseFolds=1: */

/*
 * $Id$
 *
 * Copyright (C) 2004, 2005 Slava Pestov.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package factor.jedit;

import factor.*;
import java.util.*;
import javax.swing.*;
import org.gjt.sp.jedit.textarea.*;
import org.gjt.sp.jedit.*;
import sidekick.*;

public class FactorVocabCompletion extends AbstractCompletion
{
	private String vocab;

	//{{{ FactorVocabCompletion constructor
	public FactorVocabCompletion(View view, String vocab, FactorParsedData data)
	{
		super(view,data);
		String[] completions = FactorPlugin.getVocabCompletions(
			vocab,false);
		this.items = Arrays.asList(completions);
		this.vocab = vocab;
	} //}}}

	public String getLongestPrefix()
	{
		return MiscUtilities.getLongestPrefix(items,false);
	}

	public void insert(int index)
	{
		String selected = ((String)get(index));
		String insert = selected.substring(vocab.length());

		Buffer buffer = textArea.getBuffer();

		textArea.setSelectedText(insert);
	}

	public int getTokenLength()
	{
		return vocab.length();
	}

	public boolean handleKeystroke(int selectedIndex, char keyChar)
	{
		if(keyChar == '\t' || keyChar == '\n')
		{
			insert(selectedIndex);
			return false;
		}
		else if(keyChar == ' ')
		{
			insert(selectedIndex);
			textArea.userInput(' ');
			return false;
		}
		else
		{
			textArea.userInput(keyChar);
			return true;
		}
	}
}
