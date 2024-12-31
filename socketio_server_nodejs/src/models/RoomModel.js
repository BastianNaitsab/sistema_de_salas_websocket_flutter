class RoomModel {
    constructor({ idRoom, name, dateCreation, dateStarted, listUsers, limitUsers, limitTime, state }) {
        this.idRoom = idRoom;
        this.name = name;
        this.dateCreation = dateCreation || new Date().toISOString();
        this.dateStarted = dateStarted || new Date().toISOString();
        this.listUsers = listUsers || [];
        this.limitUsers = limitUsers || 2;
        this.limitTime = limitTime || 1;
        this.state = state || "loading";
    }

    // Convertir el objeto RoomModel a un mapa
    toMap() {
        return {
            idRoom: this.idRoom,
            name: this.name,
            dateCreation: this.dateCreation,
            dateStarted: this.dateStarted,
            listUsers: this.listUsers,
            limitUsers: this.limitUsers,
            limitTime: this.limitTime,
            state: this.state
        };
    }

    // Convertir el objeto RoomModel a JSON (cadena de texto)
    toJson() {
        return JSON.stringify(this.toMap()); // Serializar el mapa a JSON
    }

    // Crear un RoomModel a partir de un mapa
    static fromMap(map) {
        return new RoomModel(
            map.idRoom,
            map.name,
            map.dateCreation,
            map.dateStarted,
            map.listUsers,
            map.limitUsers,
            map.limitTime,
            map.state
        );
    }

    // Crear un RoomModel a partir de JSON
    static fromJson(source) {
        return RoomModel.fromMap(JSON.parse(source)); // Deserializar el JSON
    }
}

module.exports = RoomModel;
