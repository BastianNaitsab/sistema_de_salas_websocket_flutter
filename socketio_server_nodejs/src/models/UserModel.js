class UserModel {
    constructor(idUser) {
        this.idUser = idUser;
    }

    toMap() {
        return {
            idUser: this.idUser,
        };
    }

    // Para enviar en websocket
    toJson() {
        return JSON.stringify(this.toMap());
    }

    static fromMap(map) {
        return new UserModel(map.idUser);
    }

    // Para recibir en websocket
    static fromJson(source) {
        return UserModel.fromMap(JSON.parse(source));
    }

}

module.exports = UserModel;