

class Team {

  String? id;
  String? nombre;
  int? votos;

  Team({
    required this.id,
    required this.nombre,
    required this.votos,
  });

  factory Team.fromMap( Map<String,dynamic> obj ) => Team(
    id     : obj.containsKey('id') ? obj['id'] : 'no-id', 
    nombre : obj.containsKey('nombre') ? obj['nombre'] : 'no-nombre', 
    votos  : obj.containsKey('votos') ? obj['votos'] : 'no-votos',
  );

}