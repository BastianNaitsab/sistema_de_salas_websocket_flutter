const { Server } = require("socket.io");  // Importa Socket.IO
const Message = require("./models/Message");
const RoomModel = require("./models/RoomModel");
const UserModel = require("./models/UserModel");

const TimeCountdown = require("./utils/TimeCountdown");
// Para escuchar se usa socket.on
// Para madar se usa socket.emit

const timeCountdown = new TimeCountdown();

const io = new Server(3000, {
    cors: {
        origin: ["http://localhost:3000", "http://mi-cliente.com"], // Permite solo conexiones desde estos origenes
        methods: ["GET", "POST"],
    },
});

// Array para almacenar las salas
let rooms = [];

let counterRooms = 0;

let lastRoom = null;

// Bandera de bloqueo
let isProcessingJoin = false;

function createNewRoom() {

    const newRoom = new RoomModel({
        idRoom: counterRooms, // Asignar el idRoom incremental
        name: `Room ${counterRooms}` // Nombre de la sala
    });

    counterRooms++; // Incrementar el contador

    // Actualizar la última sala creada
    lastRoom = newRoom;

    console.log(`Sala ${lastRoom.name} creada`);
}

function saveRoom() {
    rooms.push(lastRoom); // Agregar la nueva sala al array de salas
    console.log("Sala guardada:", lastRoom);
}

function removeExpiredRooms() {
    // Filtramos las salas que aún no han pasado el tiempo límite
    rooms = rooms.filter(room => {
        // Aca se debe cambiar por Dias caundo este en produccion
        // Usamos el método hasXMinutesPassed para verificar si el limitTime ha pasado
        return !timeCountdown.hasXMinutesPassed(room.dateStarted, room.limitTime);
    });

    console.log("Salas después de eliminar las expiradas:", rooms);
}

createNewRoom();

// Maneja la conexión en el servidor
io.on("connection", (socket) => {
    console.log(`Un cliente se ha conectado con id: ${socket.id}`);

    // Envair ultima sala apenas se conecte
    encodedRoom = lastRoom.toJson();
    socket.emit("lastRoom", encodedRoom);

    // Manejo de la desconexión del cliente
    socket.on("disconnect", () => {
        console.log(`El cliente ${socket.id} se ha desconectado`);
    });

    // Manejo de error en el socket
    socket.on("error", (err) => {
        console.log("Error en el socket:", err);
    });


    // data sera UserModel
    socket.on("join", (data) => {
        if (isProcessingJoin) {
            console.log("Proceso de unión en curso. El usuario tendrá que esperar.");
            return; // Si ya hay un proceso en curso, el usuario espera
        }

        // Inicia el bloqueo
        isProcessingJoin = true;

        // Decodificando User
        const decodedUser = UserModel.fromJson(data);
        const idUser = decodedUser.idUser;

        // Para encodificar la Room
        let encodedRoom = null;

        // Verificar si el límite de usuarios de la sala no ha sido alcanzado
        if (lastRoom.listUsers.length < lastRoom.limitUsers) {
            // Agregar el usuario a la lista de usuarios de la sala
            lastRoom.listUsers.push(decodedUser);

            // El cliente se une a la sala
            socket.join(lastRoom.idRoom);

            // Codificando Room
            encodedRoom = lastRoom.toJson();

            // Enviar room a todos los miembros de la sala
            io.to(lastRoom.idRoom).emit("room", encodedRoom);
        } else {
            // Aqui podria mejroar esto, apra que apenas este lleno cambie los estados
            lastRoom.dateStarted = new Date().toISOString();
            lastRoom.state = "full";

            // Guardar sala en Array o bbdd
            saveRoom();

            // Codificando Room
            encodedRoom = lastRoom.toJson();

            // Enviar room  con los ultimos cambios a todos los miembros de la sala
            io.to(lastRoom.idRoom).emit("room", encodedRoom);

            // Si la sala está llena
            console.log("La sala está llena:", encodedRoom);

            // Para eliminar la sala socket cuando use bbdd
            // socket.leave('lastRoom.idRoom');

            // Crea una nueva sala
            createNewRoom();

            // Agregar el usuario a la lista de usuarios de la sala
            lastRoom.listUsers.push(decodedUser);

            // El cliente se une a la sala
            socket.join(lastRoom.idRoom);

            // Codificando Room
            encodedRoom = lastRoom.toJson();

            // Enviar room a todos los clientes
            io.to(lastRoom.idRoom).emit("room", encodedRoom);
            removeExpiredRooms();
        }


        // Termina el proceso de unión, liberando el bloqueo
        isProcessingJoin = false;

        // Para enviar la ultima sala creada
        encodedRoom = lastRoom.toJson();
        io.emit("lastRoom", encodedRoom);

        console.log("Room enviada:", encodedRoom);
        console.log(`El usuario ${idUser} se ha unido a la sala ${lastRoom.name}`);

    });

});

// Manejo de error en el server
io.on("error", (err) => {
    console.error("Error en el servidor Socket.IO:", err);
});

console.log("Servidor Salas Socket.IO escuchando en el puerto 3000...");