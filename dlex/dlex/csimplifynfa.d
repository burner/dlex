module dlex.csimplifynfa;

import dlex.cnfa;
import dlex.cspec;
import dlex.cset;
import dlex.sparsebitset;

import hurt.conv.conv;
import hurt.util.stacktrace;

import std.stdio;

class CSimplifyNfa {
	private int[] ccls; // character class mapping.
	private int original_charset_size; // original charset size
	private int mapped_charset_size; // reduced charset size

	void simplify(CSpec m_spec) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"simplify");
		debug st.putArgs("string", "m_spec", m_spec.toString());
			
		computeClasses(m_spec); // initialize fields.
		
		// now rewrite the NFA using our character class mapping.
		//for(Enumeration!(long) e = m_spec.m_nfa_states.elements(); e.hasMoreElements(); ) {
		foreach(it;m_spec.m_nfa_states.elements()) {
			CNfa nfa = it;
			if(nfa.m_edge == CNfa.EMPTY || nfa.m_edge==CNfa.EPSILON)
				continue; // no change.
			if(nfa.m_edge == CNfa.CCL) {
				CSet ncset = new CSet();
				ncset.map(nfa.m_set, ccls); // map it.
				nfa.m_set = ncset;
			} else { // single character
				nfa.m_edge = ccls[nfa.m_edge]; // map it.
			}
		}

		// now update m_spec with the mapping.
		m_spec.m_ccls_map = ccls;
		m_spec.m_dtrans_ncols = mapped_charset_size;
	}

	/** Compute minimum set of character classes needed to disambiguate
	 *	edges.	We optimistically assume that every character belongs to
	 *	a single character class, and then incrementally split classes
	 *	as we see edges that require discrimination between characters in
	 *	the class. [CSA, 25-Jul-1999] */
	private void computeClasses(CSpec m_spec) {
		debug scope StackTrace st = new StackTrace(__FILE__, __LINE__,
			"computeClasses");
		debug st.putArgs("string", "m_spec", m_spec.toString());
			
		this.original_charset_size = m_spec.m_dtrans_ncols;
		this.ccls = new int[original_charset_size]; // initially all zero.

		int nextcls = 1;
		SparseBitSet clsA = new SparseBitSet(), clsB = new SparseBitSet();
		int[string] h;
		
		write("Working on character classes.");
		//for(Enumeration e=m_spec.m_nfa_states.elements(); e.hasMoreElements(); ) {
		foreach(it;m_spec.m_nfa_states.elements()) {
			CNfa nfa = it;
			if(nfa.m_edge == CNfa.EMPTY || nfa.m_edge==CNfa.EPSILON)
				continue; // no discriminatory information.
			clsA.clearAll(); clsB.clearAll();
			for(int i = 0; i < ccls.length; i++)
				if(nfa.m_edge == i || // edge labeled with a character
						nfa.m_edge == CNfa.CCL && nfa.m_set.contains(i)) // set of characters
					clsA.set(ccls[i]);
				else
					clsB.set(ccls[i]);

			// now figure out which character classes we need to split.
			clsA.and(clsB); // split the classes which show up on both sides of edge
			write(clsA.getSize() == 0 ? "." : ":");
			if(clsA.getSize() == 0) 
				continue; // nothing to do.
			// and split them.

			//h.clear(); // h will map old to new class name
			// this should clear the associated array TODO find a better solution
			foreach(hit; h.keys()) {
				h.remove(hit);
			}
			debug assert(h.length == 0, "clearing the associated array failed");

			for(int i = 0; i < ccls.length; i++) {
				if(clsA.get(ccls[i])) { // a split class
					if(nfa.m_edge == i || nfa.m_edge == CNfa.CCL && nfa.m_set.contains(i)) { // on A side
						int split = ccls[i];
						//if(!h.containsKey(split)) {
						if(conv!(int,string)(split) !in h) {
							h[conv!(int,string)(split)] = nextcls++; // make new class
						}

						ccls[i] = h[conv!(int,string)(split)];
					}
				}
			}
		}
		writeln();
		writeln("NFA has " ~ conv!(int,string)(nextcls) ~ " distinct character classes.");
		
		this.mapped_charset_size = nextcls;
	}
}
