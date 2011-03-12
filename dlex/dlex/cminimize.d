module dlex.cminimize;

import dlex.caccept;
import dlex.cdtrans;
import dlex.cspec;
import dlex.cutility;
import dlex.sparsebitset;

import hurt.container.vector;
import hurt.conv.conv;
import hurt.util.array;

import std.stdio;

class CMinimize {
	/***************************************************************
	  Member Variables
	 **************************************************************/
	CSpec m_spec;
	Vector!(Vector!(CDTrans)) m_group;
	int m_ingroup[];

	/***************************************************************
		Function: CMinimize
		Description: Constructor.
	 **************************************************************/
	this() {
		reset();
	}

	/***************************************************************
		Function: reset
		Description: Resets member variables.
	 **************************************************************/
	private void reset() {
		m_spec = null;
		m_group = null;
		m_ingroup = null;
	}

	/***************************************************************
		Function: set
		Description: Sets member variables.
	 **************************************************************/
	private void set(CSpec spec) {
		if(CUtility.DEBUG) {
			assert(null !is spec);
		}

		m_spec = spec;
		m_group = null;
		m_ingroup = null;
	}

	/***************************************************************
		Function: min_dfa
		Description: High-level access function to module.
	 **************************************************************/
	void min_dfa(CSpec spec) {
		set(spec);

		/* Remove redundant states. */
		minimize();

		/* Column and row compression. 
		   Save accept states in auxilary vector. */
		reduce();

		reset();
	}

	/***************************************************************
		Function: col_copy
		Description: Copies source column into destination column.
	 **************************************************************/
	private void col_copy(int dest, int src) {
		int n;
		int i;
		CDTrans dtrans;

		n = m_spec.m_dtrans_vector.getSize();
		for(i = 0; i < n; ++i) {
			dtrans = m_spec.m_dtrans_vector.get(i);
			dtrans.m_dtrans[dest] = dtrans.m_dtrans[src]; 
		}
	}	

	/***************************************************************
		Function: trunc_col
		Description: Truncates each column to the 'correct' length.
	 **************************************************************/
	private void trunc_col() {
		int n;
		int i;
		CDTrans dtrans;

		n = m_spec.m_dtrans_vector.getSize();
		for(i = 0; i < n; ++i) {
			int[] ndtrans = new int[m_spec.m_dtrans_ncols];
			dtrans = m_spec.m_dtrans_vector.get(i);
			arrayCopy(dtrans.m_dtrans, 0, ndtrans, 0, ndtrans.length);
			dtrans.m_dtrans = ndtrans;
		}
	}
	/***************************************************************
		Function: row_copy
		Description: Copies source row into destination row.
	 **************************************************************/
	private void row_copy(int dest, int src) {
		CDTrans dtrans;

		dtrans = m_spec.m_dtrans_vector.get(src);
		m_spec.m_dtrans_vector.insert(dest,dtrans); 
	}	

	/***************************************************************
		Function: col_equiv
		Description: 
	 **************************************************************/
	private bool col_equiv(int col1, int col2) {
		int n;
		int i;
		CDTrans dtrans;

		n = m_spec.m_dtrans_vector.getSize();
		for(i = 0; i < n; ++i) {
			dtrans = m_spec.m_dtrans_vector.get(i);
			if(dtrans.m_dtrans[col1] != dtrans.m_dtrans[col2]) {
				return false;
			}
		}

		return true;
	}

	/***************************************************************
		Function: row_equiv
		Description: 
	 **************************************************************/
	private bool row_equiv(int row1, int row2) {
		int i;
		CDTrans dtrans1;
		CDTrans dtrans2;

		dtrans1 = m_spec.m_dtrans_vector.get(row1);
		dtrans2 = m_spec.m_dtrans_vector.get(row2);

		for(i = 0; i < m_spec.m_dtrans_ncols; ++i) {
			if(dtrans1.m_dtrans[i] != dtrans2.m_dtrans[i]) {
				return false;
			}
		}

		return true;
	}

	/***************************************************************
		Function: reduce
		Description: 
	 **************************************************************/
	private void reduce() {
		int i;
		int j;
		int k;
		int nrows;
		int reduced_ncols;
		int reduced_nrows;
		SparseBitSet set;
		CDTrans dtrans;
		int size;

		set = new SparseBitSet();

		/* Save accept nodes and anchor entries. */
		size = m_spec.m_dtrans_vector.getSize();
		m_spec.m_anchor_array = new int[size];
		m_spec.m_accept_vector = new Vector!(CAccept)();
		for(i = 0; i < size; ++i) {
			dtrans = m_spec.m_dtrans_vector.get(i);
			m_spec.m_accept_vector.append(dtrans.m_accept);
			m_spec.m_anchor_array[i] = dtrans.m_anchor;
			dtrans.m_accept = null;
		}

		/* Allocate column map. */
		m_spec.m_col_map = new int[m_spec.m_dtrans_ncols];
		for(i = 0; i < m_spec.m_dtrans_ncols; ++i) {
			m_spec.m_col_map[i] = -1;
		}

		/* Process columns for reduction. */
		for(reduced_ncols = 0; ; ++reduced_ncols) {
			if(CUtility.DEBUG) {
				for(i = 0; i < reduced_ncols; ++i) {
					assert(-1 != m_spec.m_col_map[i]);
				}
			}

			for(i = reduced_ncols; i < m_spec.m_dtrans_ncols; ++i) {
				if(-1 == m_spec.m_col_map[i]) {
					break;
				}
			}

			if(i >= m_spec.m_dtrans_ncols) {
				break;
			}

			if(CUtility.DEBUG) {
				assert(false == set.get(i));
				assert(-1 == m_spec.m_col_map[i]);
			}

			set.set(i);

			m_spec.m_col_map[i] = reduced_ncols;

			/* UNDONE: Optimize by doing all comparisons in one batch. */
			for(j = i + 1; j < m_spec.m_dtrans_ncols; ++j) {
				if(-1 == m_spec.m_col_map[j] && true == col_equiv(i,j)) {
					m_spec.m_col_map[j] = reduced_ncols;
				}
			}
		}

		/* Reduce columns. */
		k = 0;
		for(i = 0; i < m_spec.m_dtrans_ncols; ++i) {
			if(set.get(i)) {
				++k;

				set.clear(i);

				j = m_spec.m_col_map[i];

				if(CUtility.DEBUG) {
					assert(j <= i);
				}

				if(j == i) {
					continue;
				}

				col_copy(j,i);
			}
		}
		m_spec.m_dtrans_ncols = reduced_ncols;
		/* truncate m_dtrans at proper length (freeing extra) */
		trunc_col();

		if(CUtility.DEBUG) {
			assert(k == reduced_ncols);
		}

		/* Allocate row map. */
		nrows = m_spec.m_dtrans_vector.getSize();
		m_spec.m_row_map = new int[nrows];
		for(i = 0; i < nrows; ++i) {
			m_spec.m_row_map[i] = -1;
		}

		/* Process rows to reduce. */
		for(reduced_nrows = 0; ; ++reduced_nrows) {
			if(CUtility.DEBUG) {
				for(i = 0; i < reduced_nrows; ++i) {
					assert(-1 != m_spec.m_row_map[i]);
				}
			}

			for(i = reduced_nrows; i < nrows; ++i) {
				if(-1 == m_spec.m_row_map[i]) {
					break;
				}
			}

			if(i >= nrows) {
				break;
			}

			if(CUtility.DEBUG) {
				assert(false == set.get(i));
				assert(-1 == m_spec.m_row_map[i]);
			}

			set.set(i);

			m_spec.m_row_map[i] = reduced_nrows;

			/* UNDONE: Optimize by doing all comparisons in one batch. */
			for(j = i + 1; j < nrows; ++j) {
				if(-1 == m_spec.m_row_map[j] && true == row_equiv(i,j)) {
					m_spec.m_row_map[j] = reduced_nrows;
				}
			}
		}

		/* Reduce rows. */
		k = 0;
		for(i = 0; i < nrows; ++i) {
			if(set.get(i)) {
				++k;

				set.clear(i);

				j = m_spec.m_row_map[i];

				if(CUtility.DEBUG) {
					assert(j <= i);
				}

				if(j == i) {
					continue;
				}

				row_copy(j,i);
			}
		}
		m_spec.m_dtrans_vector.setSize(reduced_nrows);

		if(CUtility.DEBUG) {
			/*writeln("k = " + k + "\nreduced_nrows = " + reduced_nrows + "");*/
			assert(k == reduced_nrows);
		}
	}

	/***************************************************************
Function: fix_dtrans
Description: Updates CDTrans table after minimization 
using groups, removing redundant transition table states.
	 **************************************************************/
	private void fix_dtrans() {
		Vector!(CDTrans) new_vector;
		int i;
		int size;
		Vector!(CDTrans) dtrans_group;
		CDTrans first;
		int c;

		new_vector = new Vector!(CDTrans)();

		size = m_spec.m_state_dtrans.length;
		for(i = 0; i < size; ++i) {
			if(CDTrans.F != m_spec.m_state_dtrans[i]) {
				m_spec.m_state_dtrans[i] = m_ingroup[m_spec.m_state_dtrans[i]];
			}
		}

		size = m_group.getSize();
		for(i = 0; i < size; ++i) {
			dtrans_group = m_group.get(i);
			first = dtrans_group.get(0);
			new_vector.append(first);

			for(c = 0; c < m_spec.m_dtrans_ncols; ++c) {
				if(CDTrans.F != first.m_dtrans[c]) {
					first.m_dtrans[c] = m_ingroup[first.m_dtrans[c]];
				}
			}
		}

		m_group = null;
		m_spec.m_dtrans_vector = new_vector;
	}

	/***************************************************************
		Function: minimize
		Description: Removes redundant transition table states.
	 **************************************************************/
	private void minimize() {
		Vector!(CDTrans) dtrans_group;
		Vector!(CDTrans) new_group;
		int i;
		int j;
		int old_group_count;
		int group_count;
		CDTrans next;
		CDTrans first;
		int goto_first;
		int goto_next;
		int c;
		int group_size;
		bool added;

		init_groups();

		group_count = m_group.getSize();
		old_group_count = group_count - 1;

		while(old_group_count != group_count) {
			old_group_count = group_count;

			if(CUtility.DEBUG) {
				assert(m_group.getSize() == group_count);
			}

			for(i = 0; i < group_count; ++i) {
				dtrans_group = m_group.get(i);

				group_size = dtrans_group.getSize();
				if(group_size <= 1) {
					continue;
				}

				new_group = new Vector!(CDTrans)();
				added = false;

				first = dtrans_group.get(0);
				for(j = 1; j < group_size; ++j) {
					next = dtrans_group.get(j);

					for(c = 0; c < m_spec.m_dtrans_ncols; ++c) {
						goto_first = first.m_dtrans[c];
						goto_next = next.m_dtrans[c];

						if(goto_first != goto_next
								&& (goto_first == CDTrans.F
									|| goto_next == CDTrans.F
									|| m_ingroup[goto_next] != m_ingroup[goto_first]))
								{
							if(CUtility.DEBUG) {
								assert(dtrans_group.get(j) == next);
							}

							dtrans_group.remove(j);
							--j;
							--group_size;
							new_group.append(next);
							//if(false == added) {
							if(!added) {
								added = true;
								++group_count;
								m_group.append(new_group);
							}
							m_ingroup[next.m_label] = m_group.getSize() - 1;

							if(CUtility.DEBUG) {
								assert(m_group.contains(new_group) == true);
								assert(m_group.contains(dtrans_group) == true);
								assert(dtrans_group.contains(first) == true);
								assert(dtrans_group.contains(next) == false);
								assert(new_group.contains(first) == false);
								assert(new_group.contains(next) == true);
								assert(dtrans_group.getSize() == group_size);
								assert(i == m_ingroup[first.m_label]);
								assert((m_group.getSize() - 1) == m_ingroup[next.m_label]);
							}

							break;
						}
					}
				}
			}
		}

		writeln(conv!(uint,string)(m_group.getSize()) ~ " states after removal of redundant states.");

		if(m_spec.m_verbose && true == CUtility.OLD_DUMP_DEBUG) {
			writeln();
			writeln("States grouped as follows after minimization");
			pgroups();
		}

		fix_dtrans();
	}

	/***************************************************************
		Function: init_groups
		Description:
	 **************************************************************/
	private void init_groups() {
		int i;
		int j;
		int group_count;
		int size;
		CAccept accept;
		CDTrans dtrans;
		Vector!(CDTrans) dtrans_group;
		CDTrans first;
		bool group_found;

		m_group = new Vector!(Vector!(CDTrans))();
		group_count = 0;

		size = m_spec.m_dtrans_vector.getSize();
		m_ingroup = new int[size];

		for(i = 0; i < size; ++i) {
			group_found = false;
			dtrans = m_spec.m_dtrans_vector.get(i);

			if(CUtility.DEBUG) {
				assert(i == dtrans.m_label);
				assert(false == group_found);
				assert(group_count == m_group.getSize());
			}

			for(j = 0; j < group_count; ++j) {
				dtrans_group = m_group.get(j);

				if(CUtility.DEBUG) {
					assert(false == group_found);
					assert(0 < dtrans_group.getSize());
				}

				first = dtrans_group.get(0);

				if(CUtility.SLOW_DEBUG) {
					CDTrans check;
					int k;
					int s;

					s = dtrans_group.getSize();
					assert(0 < s);

					for(k = 1; k < s; ++k) {
						check = dtrans_group.get(k);
						assert(check.m_accept == first.m_accept);
					}
				}

				if(first.m_accept == dtrans.m_accept) {
					dtrans_group.append(dtrans);
					m_ingroup[i] = j;
					group_found = true;

					if(CUtility.DEBUG) {
						assert(j == m_ingroup[dtrans.m_label]);
					}

					break;
				}
			}

			if(false == group_found) {
				dtrans_group = new Vector!(CDTrans)();
				dtrans_group.append(dtrans);
				m_ingroup[i] = m_group.getSize();
				m_group.append(dtrans_group);
				++group_count;
			}
		}

		if(m_spec.m_verbose && true == CUtility.OLD_DUMP_DEBUG) {
			writeln("Initial grouping:");
			pgroups();
			writeln();
		}
	}

	/***************************************************************
		Function: pset
	 **************************************************************/
	private void pset(Vector!(CDTrans) dtrans_group) {
		int i;
		int size;
		CDTrans dtrans;

		size = dtrans_group.getSize();
		for(i = 0; i < size; ++i) {
			dtrans = dtrans_group.get(i);
			write(conv!(int,string)(dtrans.m_label) ~ " ");
		}
	}

	/***************************************************************
		Function: pgroups
	 **************************************************************/
	private void pgroups() {
		int i;
		int dtrans_size;
		int group_size;

		group_size = m_group.getSize();
		for(i = 0; i < group_size; ++i) {
			write("\tGroup " ~ conv!(int,string)(i) ~ " {");
			pset(m_group.get(i));
			writeln("}");
			writeln();
		}

		writeln();
		dtrans_size = m_spec.m_dtrans_vector.getSize();
		for(i = 0; i < dtrans_size; ++i) {
			writeln("\tstate " ~ conv!(int,string)(i)
					~ " is in group " 
					~ conv!(int,string)(m_ingroup[i]));
		}
	}
}
