<%@page contentType="text/html" pageEncoding="UTF-8"%>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
    <title>Problem 4</title>
    <style>
      table{
        border: 1px solid;
        border-collapse: collapse;
        text-align: center;
        width: 330px;
        font-size: 18px;
      }
      th{
        font-weight: bold;
        border: 1px solid;
      }
      td{
        border: 1px solid;
      }
    </style>
  </head>
  <body style="font-family:'Times New Roman';">
    <h1>City Location</h1>
    <table>
      <tr>
        <td><b>City</b></td>
        <td><b>Latitude</b></td>
        <td><b>Longitude</b></td>
      </tr>
      <tr>
        <td>London</td>
        <td>52.0</td>
        <td>0.0</td>
      </tr>
      <tr>
        <td>NewYork</td>
        <td>41.0</td>
        <td>-74.0</td>
      </tr>
      <tr>
        <td>Seoul</td>
        <td>38.0</td>
        <td>127.0</td>
      </tr>
    </table>
  </body>
  <%@ page import = "java.sql.*" %>
</html>
