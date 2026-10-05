/// Aladhan API calculation methods (subset relevant to Central Asia / CIS).
/// See https://aladhan.com/calculation-methods
enum CalculationMethod {
  muslimWorldLeague(3, 'Muslim World League'),
  diyanet(13, 'Diyanet (Turkiya)'),
  spiritualAdministrationOfMuslimsOfRussia(14, 'Rossiya musulmonlari boshqarmasi'),
  karachi(1, 'University of Islamic Sciences, Karachi'),
  egyptian(5, 'Egyptian General Authority of Survey');

  const CalculationMethod(this.id, this.label);

  final int id;
  final String label;
}
