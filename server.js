import 'dotenv/config';
import express from 'express';
import mysql from 'mysql2/promise';
import crypto from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const app=express();
const port=Number(process.env.PORT||3000);
const pool=mysql.createPool({host:process.env.DB_HOST||'localhost',port:Number(process.env.DB_PORT||3306),user:process.env.DB_USER||'root',password:process.env.DB_PASSWORD||'',database:process.env.DB_NAME||'daybook',waitForConnections:true,connectionLimit:Number(process.env.DB_POOL_SIZE||10),decimalNumbers:true,dateStrings:true});
const currencies=new Set(['GBP','USD','EUR','INR','JPY','CAD','AUD','GEL']);
const categories=new Set(['Food','Transport','Shopping','Bills','Health','Entertainment','Travel','Other']);
const clean=s=>typeof s==='string'?s.trim():'';
const validId=id=>/^[0-9a-f-]{36}$/i.test(id||'');

app.use(express.json({limit:'32kb'}));

app.get('/api/health',async(_req,res,next)=>{try{await pool.query('SELECT 1');res.json({status:'ok',database:'connected'})}catch(e){next(e)}});
app.get('/api/users',async(_req,res,next)=>{try{const [rows]=await pool.query('SELECT id,name,email,currency,monthly_budget AS budget,color FROM users ORDER BY created_at');res.json(rows)}catch(e){next(e)}});
app.post('/api/users',async(req,res,next)=>{try{const name=clean(req.body.name),email=clean(req.body.email).toLowerCase(),currency=clean(req.body.currency).toUpperCase();if(!name||!/^\S+@\S+\.\S+$/.test(email)||!currencies.has(currency))return res.status(400).json({error:'Valid name, email and currency are required.'});const row={id:crypto.randomUUID(),name,email,currency,budget:2500,color:clean(req.body.color)||'#1d654f'};await pool.execute('INSERT INTO users (id,name,email,currency,monthly_budget,color) VALUES (?,?,?,?,?,?)',[row.id,row.name,row.email,row.currency,row.budget,row.color]);res.status(201).json(row)}catch(e){next(e)}});
app.patch('/api/users/:id',async(req,res,next)=>{try{if(!validId(req.params.id))return res.status(400).json({error:'Invalid user id.'});const budget=Number(req.body.budget),currency=clean(req.body.currency).toUpperCase();if(!(budget>=0)||!currencies.has(currency))return res.status(400).json({error:'Valid budget and currency are required.'});const [result]=await pool.execute('UPDATE users SET monthly_budget=?,currency=? WHERE id=?',[budget,currency,req.params.id]);if(!result.affectedRows)return res.status(404).json({error:'User not found.'});res.json({budget,currency})}catch(e){next(e)}});
app.get('/api/expenses',async(req,res,next)=>{try{if(!validId(req.query.userId))return res.status(400).json({error:'Valid userId is required.'});const [rows]=await pool.execute('SELECT id,user_id AS userId,merchant,amount,currency,category,expense_date AS date,note FROM expenses WHERE user_id=? ORDER BY expense_date DESC,created_at DESC',[req.query.userId]);res.json(rows)}catch(e){next(e)}});
app.post('/api/expenses',async(req,res,next)=>{try{const userId=clean(req.body.userId),merchant=clean(req.body.merchant),currency=clean(req.body.currency).toUpperCase(),category=clean(req.body.category),date=clean(req.body.date),note=clean(req.body.note)||null,amount=Number(req.body.amount);if(!validId(userId)||!merchant||!(amount>0)||!currencies.has(currency)||!categories.has(category)||!/^\d{4}-\d{2}-\d{2}$/.test(date))return res.status(400).json({error:'Invalid expense data.'});const row={id:crypto.randomUUID(),userId,merchant,amount,currency,category,date,note};await pool.execute('INSERT INTO expenses (id,user_id,merchant,amount,currency,category,expense_date,note) VALUES (?,?,?,?,?,?,?,?)',[row.id,userId,merchant,amount,currency,category,date,note]);res.status(201).json(row)}catch(e){next(e)}});
app.delete('/api/expenses/:id',async(req,res,next)=>{try{if(!validId(req.params.id))return res.status(400).json({error:'Invalid expense id.'});const [result]=await pool.execute('DELETE FROM expenses WHERE id=?',[req.params.id]);if(!result.affectedRows)return res.status(404).json({error:'Expense not found.'});res.status(204).end()}catch(e){next(e)}});

const root=path.dirname(fileURLToPath(import.meta.url));app.use(express.static(root));app.get('*',(_req,res)=>res.sendFile(path.join(root,'index.html')));
app.use((err,_req,res,_next)=>{console.error(err);if(err.code==='ER_DUP_ENTRY')return res.status(409).json({error:'That email address already exists.'});if(err.code==='ER_NO_SUCH_TABLE'||err.code==='ER_BAD_DB_ERROR'||err.code==='ECONNREFUSED')return res.status(503).json({error:'Database unavailable. Import schema.sql and check your .env settings.'});res.status(500).json({error:'Unexpected server error.'})});
app.listen(port,()=>console.log(`Daybook running at http://localhost:${port}`));
