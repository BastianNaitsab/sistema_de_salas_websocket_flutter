class TimeCountdown {

    hasXDaysPassed(date, days) {
        const now = new Date(); // Obtenemos la fecha actual
        const difference = now - new Date(date); // Diferencia en milisegundos

        // Verificamos si han pasado al menos 14 días (14 * 24 * 60 * 60 * 1000 ms)
        return difference >= days * 24 * 60 * 60 * 1000;
    }

    // Método dinámico para verificar si han pasado X minutos
    hasXMinutesPassed(date, minutes) {
        const now = new Date(); // Obtenemos la fecha actual
        const difference = now - new Date(date); // Diferencia en milisegundos

        // Verificamos si han pasado al menos X minutos (X * 60 * 1000 ms)
        return difference >= minutes * 60 * 1000;
    }
}

module.exports = TimeCountdown;
