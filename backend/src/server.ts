import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'

dotenv.config();

const PORT = process.env.PORT || 4000;
const app = express();

app.use(cors());

app.get('/', (req, res)=>{

    return res.status(200).json({
        success: "API testing successfull"
    }) 
});

app.listen(PORT, ()=>{
    console.log(`Server is listening on PORT ${PORT}`)
})
