const mongoose = require('mongoose')
const URL = process.env.MONGO_URI

mongoose.connect(URL, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
mongoose.Promise = global.Promise

const db = mongoose.connection
db.on('connected', () => {
    console.log("✅ Connected to MongoDB")
})

db.on('error', (err) => {
    console.error("❌ DB ERROR:", err)
})

db.on('disconnected', () => {
    console.log("⚠️ MongoDB disconnected")
})

module.exports = {db, mongoose}
