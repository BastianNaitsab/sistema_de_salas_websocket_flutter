class UserModel {
    constructor(idUser) {
        this.idUser = idUser;
    }

    toMap() {
        return {
            idUser: this.idUser,
        };
    }

    toJson() {
        return JSON.stringify(this.toMap()); // Serializar el mapa a JSON
    }

    static fromMap(map) {
        return new UserModel(map.idUser);
    }

    static fromJson(source) {
        return UserModel.fromMap(JSON.parse(source)); // Deserializar el JSON
    }

}

module.exports = UserModel;