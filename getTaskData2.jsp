<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="net.sf.json.JSONArray"%>
<%@ taglib uri="/struts-tags" prefix="s"%>
<%@ taglib uri="myapps" prefix="o"%>

<%!
	String Driver = "com.mysql.jdbc.Driver";
	String dbUrl = "jdbc:mysql://127.0.0.1:3307/pm";
	String dbUser = "root";
	String dbPassword = "123456";
	public String resultToJson(ResultSet rs) throws Exception {
		ResultSetMetaData md = rs.getMetaData();
		int columnCount = md.getColumnCount();
		ArrayList list = new ArrayList();
		Map rowData;
		while(rs.next()){
			rowData = new HashMap(columnCount);
			for(int i = 1; i <= columnCount; i++){			
				rowData.put(md.getColumnLabel(i), rs.getObject(i));
			}
			list.add(rowData);	    	
		}
		JSONArray json = JSONArray.fromObject(list);
		return json.toString();
	}
%>

<%
	String wbs = request.getParameter("wbs");
	System.out.println("wbs: "+ wbs);
	String imformation = "[]";

	try{
		Class.forName(Driver);
		Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
		Statement stmt = conn.createStatement();

        String sql = "SELECT ITEM_SEARCH_ as wbs,ITEM_NAME_ as name,ITEM_ANNEX as annex,ITEM_NOTES_ as note,ITEM_RECTIFICATION as measures, item_reportdate as handle FROM tlk_weekreport WHERE ITEM_SEARCH_ like'"+ wbs +"%'";
        ResultSet rs = stmt.executeQuery(sql);
        imformation = resultToJson(rs);
        rs.close();

		stmt.close();
		conn.close();
	}catch(ClassNotFoundException e){
		e.printStackTrace();
	}catch(SQLException e){
		e.printStackTrace();
	}catch(Exception e){
		e.printStackTrace();
	}

	response.getWriter().write(imformation);
%>