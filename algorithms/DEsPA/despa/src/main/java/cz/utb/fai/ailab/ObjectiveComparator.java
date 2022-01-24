package cz.utb.fai.ailab;

import java.io.Serializable;
import java.util.Comparator;


/**
 * Compares two solutions using the value of a specific objective.
 */
public class ObjectiveComparator implements FitnessComparator, 
Comparator<Solution>, Serializable {

	private static final long serialVersionUID = -6718367624398691971L;

	/**
	 * The objective to be compared.
	 */
	private final int objective;

	/**
	 * Constructs a comparator for comparing solutions using the value of the
	 * specified objective.
	 * 
	 * @param objective the objective to be compared
	 */
	public ObjectiveComparator(int objective) {
		this.objective = objective;
	}

	@Override
	public int compare(Solution solution1, Solution solution2) {
		double value1 = solution1.fitness[objective];
		double value2 = solution2.fitness[objective];

		return Double.compare(value1, value2);
	}

}
